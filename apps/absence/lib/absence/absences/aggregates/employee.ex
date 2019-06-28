defmodule Absence.Absences.Aggregates.Employee do
  @behaviour EventSourcing.Aggregate

  alias __MODULE__
  alias Absence.Absences.Commands.AddHours
  alias Absence.Absences.Commands.RemoveHours
  alias Absence.Absences.Commands.SetTeamLeader
  alias Absence.Absences.Commands.RequestTimeoff
  alias Absence.Absences.Commands.MakeTeamLeader
  alias Absence.Absences.Commands.ApproveTimeoffRequest
  alias Absence.Absences.Commands.RejectTimeoffRequest
  alias Absence.Absences.Events.HoursAdded
  alias Absence.Absences.Events.HoursRemoved
  alias Absence.Absences.Events.TeamLeaderSet
  alias Absence.Absences.Events.TimeoffRequested
  alias Absence.Absences.Events.TimeoffRequestApproved
  alias Absence.Absences.Events.TimeoffRequestRejected
  alias Absence.Absences.Events.TeamLeaderAwarded
  alias Absence.Absences.TimeoffRequest

  @type t :: struct()

  defstruct [
    :uuid,
    # team leader that is managing the employee
    :team_leader_uuid,
    # team leader aggregate for employee that is team leader
    :team_leader_aggregate_uuid,
    hours: 0,
    pending_timeoff_requests: [],
    approved_timeoff_requests: [],
    rejected_timeoff_requests: []
  ]

  def execute(%Employee{} = employee, %AddHours{} = add_hours) do
    %HoursAdded{
      employee_uuid: employee.uuid,
      hours: add_hours.hours
    }
  end

  def execute(%Employee{} = employee, %RemoveHours{} = remove_hours) do
    %HoursRemoved{
      employee_uuid: employee.uuid,
      hours: remove_hours.hours
    }
  end

  def execute(%Employee{} = employee, %SetTeamLeader{} = set_team_leader) do
    %TeamLeaderSet{
      employee_uuid: employee.uuid,
      team_leader_uuid: set_team_leader.team_leader_uuid
    }
  end

  def execute(%Employee{} = employee, %RequestTimeoff{} = request_timeoff) do
    %TimeoffRequested{
      employee_uuid: employee.uuid,
      timeoff_request: TimeoffRequest.from_command(request_timeoff)
    }
  end

  def execute(%Employee{} = employee, %ApproveTimeoffRequest{} = event) do
    timeoff_request = find_pending_timeoff_request(employee, event.timeoff_request_uuid)

    %TimeoffRequestApproved{
      employee_uuid: event.employee_uuid,
      team_leader_uuid: event.team_leader_uuid,
      timeoff_request: %{timeoff_request | status: :approved}
    }
  end

  def execute(%Employee{} = employee, %RejectTimeoffRequest{} = event) do
    timeoff_request = find_pending_timeoff_request(employee, event.timeoff_request_uuid)

    %TimeoffRequestRejected{
      employee_uuid: event.employee_uuid,
      team_leader_uuid: event.team_leader_uuid,
      timeoff_request: %{timeoff_request | status: :rejected}
    }
  end

  def execute(%Employee{} = employee, %MakeTeamLeader{} = make_team_leader) do
    %TeamLeaderAwarded{
      employee_uuid: employee.uuid,
      team_leader_uuid: make_team_leader.team_leader_uuid
    }
  end

  def apply(%Employee{} = employee, %HoursAdded{hours: hours}) do
    %{employee | hours: employee.hours + hours}
  end

  def apply(%Employee{} = employee, %HoursRemoved{hours: hours}) do
    %{employee | hours: employee.hours - hours}
  end

  def apply(%Employee{} = employee, %TeamLeaderSet{team_leader_uuid: uuid}) do
    %{employee | team_leader_uuid: uuid}
  end

  def apply(%Employee{} = employee, %TimeoffRequested{} = event) do
    update_in(employee.pending_timeoff_requests, &[event.timeoff_request | &1])
  end

  def apply(%Employee{} = employee, %TimeoffRequestApproved{} = event) do
    %TimeoffRequestApproved{timeoff_request: timeoff_request} = event
    employee = remove_pending_timeoff_request(employee, timeoff_request)
    update_in(employee.approved_timeoff_requests, &[timeoff_request | &1])
  end

  def apply(%Employee{} = employee, %TimeoffRequestRejected{} = event) do
    %TimeoffRequestRejected{timeoff_request: timeoff_request} = event
    employee = remove_pending_timeoff_request(employee, timeoff_request)
    update_in(employee.rejected_timeoff_requests, &[timeoff_request | &1])
  end

  def apply(%Employee{} = employee, %TeamLeaderAwarded{team_leader_uuid: uuid}) do
    %{employee | team_leader_aggregate_uuid: uuid}
  end

  defp find_pending_timeoff_request(employee, uuid) do
    Enum.find(employee.pending_timeoff_requests, &(&1.uuid == uuid))
  end

  defp remove_pending_timeoff_request(employee, %{uuid: uuid}) do
    timeoff_requests =
      Enum.reject(employee.pending_timeoff_requests, fn
        %{uuid: ^uuid} -> true
        _ -> false
      end)

    %{employee | pending_timeoff_requests: timeoff_requests}
  end
end
