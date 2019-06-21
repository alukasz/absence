defmodule Absence.Absences.Aggregates.TeamLeader do
  @behaviour EventSourcing.Aggregate

  alias __MODULE__
  alias Absence.Absences.Commands.ApproveTimeoffRequest
  alias Absence.Absences.Commands.RejectTimeoffRequest
  alias Absence.Absences.Events.TimeoffRequestApproved
  alias Absence.Absences.Events.TimeoffRequestRejected

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
      timeoff_request: %{approve_timeoff_request.timeoff_request | status: :approved}
    }
  end

  def execute(%TeamLeader{} = team_leader, %RejectTimeoffRequest{} = reject_timeoff_request) do
    %TimeoffRequestRejected{
      employee_uuid: reject_timeoff_request.employee_uuid,
      team_leader_uuid: team_leader.uuid,
      timeoff_request: %{reject_timeoff_request.timeoff_request | status: :rejected}
    }
  end

  def apply(%TeamLeader{} = team_leader, %TimeoffRequestApproved{} = timeoff_request_approved) do
    %TimeoffRequestApproved{timeoff_request: timeoff_request} = timeoff_request_approved
    update_in(team_leader.approved_timeoff_requests, &[timeoff_request | &1])
  end

  def apply(%TeamLeader{} = team_leader, %TimeoffRequestRejected{} = timeoff_request_rejected) do
    %TimeoffRequestRejected{timeoff_request: timeoff_request} = timeoff_request_rejected
    update_in(team_leader.rejected_timeoff_requests, &[timeoff_request | &1])
  end
end
