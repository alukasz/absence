defmodule Absence.Absences.Aggregates.Employee do
  @behaviour EventSourcing.Aggregate

  alias __MODULE__
  alias Absence.Absences.Commands.AddHours
  alias Absence.Absences.Commands.RemoveHours
  alias Absence.Absences.Commands.RequestTimeoff
  alias Absence.Absences.Events.HoursAdded
  alias Absence.Absences.Events.HoursRemoved
  alias Absence.Absences.Events.TimeoffRequested
  alias Absence.Absences.Events.TimeoffRequestApproved
  alias Absence.Absences.Events.TimeoffRequestRejected
  alias Absence.Absences.TimeoffRequest

  defstruct [
    :uuid,
    team_leader_uuid: nil,
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

  def execute(%Employee{} = employee, %RequestTimeoff{} = request_timeoff) do
    %TimeoffRequested{
      employee_uuid: employee.uuid,
      start_date: request_timeoff.start_date,
      end_date: request_timeoff.end_date
    }
  end

  def apply(%Employee{} = employee, %HoursAdded{hours: hours}) do
    %{employee | hours: employee.hours + hours}
  end

  def apply(%Employee{} = employee, %HoursRemoved{hours: hours}) do
    %{employee | hours: employee.hours - hours}
  end

  def apply(%Employee{} = employee, %TimeoffRequested{} = event) do
    timeoff_request = TimeoffRequest.from_event(event)
    update_in(employee.pending_timeoff_requests, &[timeoff_request | &1])
  end

  def apply(%Employee{} = employee, %TimeoffRequestApproved{} = event) do
    %TimeoffRequestApproved{timeoff_request: timeoff_request} = event
    employee = remove_pending_timeoff_request(employee, timeoff_request.uuid)
    update_in(employee.approved_timeoff_requests, &[timeoff_request | &1])
  end

  def apply(%Employee{} = employee, %TimeoffRequestRejected{} = event) do
    %TimeoffRequestRejected{timeoff_request: timeoff_request} = event
    employee = remove_pending_timeoff_request(employee, timeoff_request.uuid)
    update_in(employee.rejected_timeoff_requests, &[timeoff_request | &1])
  end

  defp remove_pending_timeoff_request(employee, uuid) do
    timeoff_requests =
      Enum.reject(employee.pending_timeoff_requests, fn
        %{uuid: ^uuid} -> true
        _ -> false
      end)

    %{employee | pending_timeoff_requests: timeoff_requests}
  end
end
