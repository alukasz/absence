defmodule Absence.Absences.Aggregates.TeamLeader do
  @behaviour EventSourcing.Aggregate

  alias __MODULE__
  alias Absence.Absences.Commands.ReviewTimeoffRequest
  alias Absence.Absences.Commands.ApproveTimeoffRequest
  alias Absence.Absences.Commands.RejectTimeoffRequest
  alias Absence.Absences.Events.TimeoffReviewRequested
  alias Absence.Absences.Events.TimeoffRequestApproved
  alias Absence.Absences.Events.TimeoffRequestRejected

  defstruct [
    :uuid,
    :employee_uuid,
    review_timeoff_requests: [],
    approved_timeoff_requests: [],
    rejected_timeoff_requests: []
  ]

  def execute(%TeamLeader{} = team_leader, %ReviewTimeoffRequest{} = review_timeoff_request) do
    %TimeoffReviewRequested{
      team_leader_uuid: team_leader.uuid,
      timeoff_request: review_timeoff_request.timeoff_request
    }
  end

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

  def apply(%TeamLeader{} = team_leader, %TimeoffReviewRequested{} = timeoff_review_requested) do
    %TimeoffReviewRequested{timeoff_request: timeoff_request} = timeoff_review_requested
    update_in(team_leader.review_timeoff_requests, &[timeoff_request | &1])
  end

  def apply(%TeamLeader{} = team_leader, %TimeoffRequestApproved{} = timeoff_request_approved) do
    %TimeoffRequestApproved{timeoff_request: timeoff_request} = timeoff_request_approved
    team_leader = remove_review_timeoff_request(team_leader, timeoff_request)
    update_in(team_leader.approved_timeoff_requests, &[timeoff_request | &1])
  end

  def apply(%TeamLeader{} = team_leader, %TimeoffRequestRejected{} = timeoff_request_rejected) do
    %TimeoffRequestRejected{timeoff_request: timeoff_request} = timeoff_request_rejected
    team_leader = remove_review_timeoff_request(team_leader, timeoff_request)
    update_in(team_leader.rejected_timeoff_requests, &[timeoff_request | &1])
  end

  defp remove_review_timeoff_request(team_leader, %{uuid: uuid}) do
    timeoff_requests =
      Enum.reject(team_leader.review_timeoff_requests, fn
        %{uuid: ^uuid} -> true
        _ -> false
      end)

    %{team_leader | review_timeoff_requests: timeoff_requests}
  end
end
