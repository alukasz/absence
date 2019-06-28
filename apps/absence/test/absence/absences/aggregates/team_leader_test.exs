defmodule Absence.Absences.Aggregates.TeamLeaderTest do
  use EventSourcing.AggregateCase, async: true

  import Absence.Factory

  alias Absence.Absences.Events.TimeoffRequestApproved
  alias Absence.Absences.Events.TimeoffRequestRejected
  alias Absence.Absences.Events.TimeoffReviewRequested
  alias Absence.Absences.EventHandlers.TimeoffEventHandler

  setup do
    team_leader = build_aggregate(:team_leader)
    employee = build_aggregate(:employee)
    timeoff_request = build_entity(:timeoff_request) |> with_employee(employee)

    {:ok, employee: employee, team_leader: team_leader, timeoff_request: timeoff_request}
  end

  describe "timeoff request to review" do
    test "ReviewTimeoffRequest adds TimeoffRequest to review", %{
      team_leader: team_leader,
      timeoff_request: timeoff_request
    } do
      command =
        build_command(:review_timeoff_request, timeoff_request: timeoff_request)
        |> with_team_leader(team_leader)

      assert aggregate_execute(team_leader, command) == %TimeoffReviewRequested{
               team_leader_uuid: team_leader.uuid,
               timeoff_request: timeoff_request
             }
    end

    test "TimeoffReviewRequested event adds TimeoffRequest to review timeoff requests", %{
      team_leader: team_leader,
      timeoff_request: timeoff_request
    } do
      event =
        build_event(:timeoff_review_requested, timeoff_request: timeoff_request)
        |> with_team_leader(team_leader)

      assert %{review_timeoff_requests: [^timeoff_request]} = aggregate_apply(team_leader, event)
    end
  end

  describe "approving timeoff requests" do
    setup :review_timeoff_request

    test "ApproveTimeoffRequest approves time off for specified employee", %{
      employee: employee,
      team_leader: team_leader,
      timeoff_request: timeoff_request
    } do
      command =
        build_command(:approve_timeoff_request, timeoff_request_uuid: timeoff_request.uuid)
        |> with_employee(employee)
        |> with_team_leader(team_leader)

      assert aggregate_execute(team_leader, command) == %TimeoffRequestApproved{
               employee_uuid: employee.uuid,
               team_leader_uuid: team_leader.uuid,
               timeoff_request: %{timeoff_request | status: :approved}
             }
    end

    test "TimeoffRequestApproved event adds TimeoffRequest to approved timeoff requests", %{
      employee: employee,
      team_leader: team_leader,
      timeoff_request: timeoff_request
    } do
      event =
        build_event(:timeoff_request_approved, timeoff_request: timeoff_request)
        |> with_employee(employee)
        |> with_team_leader(team_leader)

      assert %{approved_timeoff_requests: [^timeoff_request], rejected_timeoff_requests: []} =
               aggregate_apply(team_leader, event)
    end

    test "TimeoffRequestApproved event removes TimeoffRequest from review", %{
      employee: employee,
      team_leader: team_leader,
      timeoff_request: timeoff_request
    } do
      event =
        build_event(:timeoff_request_approved, timeoff_request: timeoff_request)
        |> with_employee(employee)
        |> with_team_leader(team_leader)

      assert %{review_timeoff_requests: []} = aggregate_apply(team_leader, event)
    end

    test "TimeoffRequestApproved event invokes TimeoffEventHandler", %{
      employee: employee,
      team_leader: team_leader,
      timeoff_request: timeoff_request
    } do
      event =
        build_event(:timeoff_request_approved, timeoff_request: timeoff_request)
        |> with_employee(employee)
        |> with_team_leader(team_leader)

      aggregate_apply(team_leader, event)

      assert event_handler_invoked(TimeoffEventHandler)
    end
  end

  describe "rejecting timeoff requests" do
    setup :review_timeoff_request

    test "RejectTimeoffRequest rejects time off for specified employee", %{
      employee: employee,
      team_leader: team_leader,
      timeoff_request: timeoff_request
    } do
      command =
        build_command(:reject_timeoff_request, timeoff_request_uuid: timeoff_request.uuid)
        |> with_employee(employee)
        |> with_team_leader(team_leader)

      assert aggregate_execute(team_leader, command) == %TimeoffRequestRejected{
               employee_uuid: employee.uuid,
               team_leader_uuid: team_leader.uuid,
               timeoff_request: %{timeoff_request | status: :rejected}
             }
    end

    test "TimeoffRequestRejected event adds TimeoffRequest to rejected timeoff requests", %{
      employee: employee,
      team_leader: team_leader,
      timeoff_request: timeoff_request
    } do
      event =
        build_event(:timeoff_request_rejected, timeoff_request: timeoff_request)
        |> with_employee(employee)
        |> with_team_leader(team_leader)

      assert %{approved_timeoff_requests: [], rejected_timeoff_requests: [^timeoff_request]} =
               aggregate_apply(team_leader, event)
    end

    test "TimeoffRequestRejected event removes TimeoffRequest from review", %{
      employee: employee,
      team_leader: team_leader,
      timeoff_request: timeoff_request
    } do
      event =
        build_event(:timeoff_request_rejected, timeoff_request: timeoff_request)
        |> with_employee(employee)
        |> with_team_leader(team_leader)

      assert %{review_timeoff_requests: []} = aggregate_apply(team_leader, event)
    end

    test "TimeoffRequestRejected event invokes TimeoffEventHandler", %{
      employee: employee,
      team_leader: team_leader,
      timeoff_request: timeoff_request
    } do
      event =
        build_event(:timeoff_request_rejected, timeoff_request: timeoff_request)
        |> with_employee(employee)
        |> with_team_leader(team_leader)

      aggregate_apply(team_leader, event)

      assert event_handler_invoked(TimeoffEventHandler)
    end
  end

  defp review_timeoff_request(%{team_leader: team_leader, timeoff_request: timeoff_request}) do
    team_leader = %{team_leader | review_timeoff_requests: [timeoff_request]}
    {:ok, team_leader: team_leader}
  end
end
