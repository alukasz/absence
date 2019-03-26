defmodule Absence.Absences.Aggregates.TeamLeader do
  @behaviour EventSourcing.Aggregate

  alias __MODULE__
  alias Absence.Absences.Commands.ApproveTimeoffRequest
  alias Absence.Absences.Commands.RejectTimeoffRequest
  alias Absence.Absences.Events.TimeoffRequestApproved
  alias Absence.Absences.Events.TimeoffRequestRejected
  alias Absence.Absences.TimeoffRequest

  defstruct [
    :uuid,
    :employee_uuid,
    approved_timeoff_requests: [],
    rejected_timeoff_requests: []
  ]

  def execute(%TeamLeader{} = team_leader, %ApproveTimeoffRequest{} = approve_timeoff_request) do
    %TimeoffRequestApproved{
      employee_uuid: approve_timeoff_request.employee_uuid,
      team_leader_uuid: team_leader.uuid,
      timeoff_request: approve_timeoff_request.timeoff_request
    }
  end

  def execute(%TeamLeader{} = team_leader, %RejectTimeoffRequest{} = approve_timeoff_request) do
    %TimeoffRequestRejected{
      employee_uuid: approve_timeoff_request.employee_uuid,
      team_leader_uuid: team_leader.uuid,
      timeoff_request: approve_timeoff_request.timeoff_request
    }
  end

  def apply(%TeamLeader{} = team_leader, %TimeoffRequestApproved{
        timeoff_request: timeoff_request
      }) do
    %{
      team_leader
      | approved_timeoff_requests: [timeoff_request | team_leader.approved_timeoff_requests]
    }
  end

  def apply(%TeamLeader{} = team_leader, %TimeoffRequestRejected{
        timeoff_request: timeoff_request
      }) do
    %{
      team_leader
      | rejected_timeoff_requests: [timeoff_request | team_leader.rejected_timeoff_requests]
    }
  end
end
