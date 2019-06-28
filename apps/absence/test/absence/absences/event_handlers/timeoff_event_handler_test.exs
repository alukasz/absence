defmodule Absence.Absences.EventHandlers.TimeoffEventHandlerTest do
  use EventSourcing.DispatcherCase, async: true

  import Absence.Factory

  alias Absence.Absences.Aggregates.Employee
  alias Absence.Absences.Aggregates.TeamLeader
  alias Absence.Absences.Commands.ReviewTimeoffRequest
  alias Absence.Absences.Commands.ApproveTimeoffRequest
  alias Absence.Absences.Commands.RejectTimeoffRequest
  alias Absence.Absences.EventHandlers.TimeoffEventHandler

  describe "TimeoffRequested event" do
    test "invokes team leader with ReviewTimeoffRequest command" do
      team_leader = build_aggregate(:team_leader)
      employee = build_aggregate(:employee) |> with_team_leader(team_leader)
      timeoff_request = build_entity(:timeoff_request) |> with_employee(employee)
      event = build_event(:timeoff_requested, timeoff_request: timeoff_request)
      team_leader_uuid = team_leader.uuid

      TimeoffEventHandler.handle_event(event, employee)

      assert_dispatched TeamLeader, ^team_leader_uuid, %ReviewTimeoffRequest{
        team_leader_uuid: ^team_leader_uuid,
        timeoff_request: ^timeoff_request
      }
    end
  end

  describe "TimeoffRequestApproved event" do
    test "invokes Employee with ApproveTimeoffRequest command" do
      team_leader = build_aggregate(:team_leader)
      employee = build_aggregate(:employee) |> with_team_leader(team_leader)
      timeoff_request = build_entity(:timeoff_request) |> with_employee(employee)

      event =
        build_event(:timeoff_request_approved, timeoff_request: timeoff_request)
        |> with_employee(employee)
        |> with_team_leader(team_leader)

      team_leader_uuid = event.team_leader_uuid
      employee_uuid = event.employee_uuid
      timeoff_request_uuid = event.timeoff_request.uuid

      TimeoffEventHandler.handle_event(event, team_leader)

      assert_dispatched Employee, ^employee_uuid, %ApproveTimeoffRequest{
        employee_uuid: ^employee_uuid,
        team_leader_uuid: ^team_leader_uuid,
        timeoff_request_uuid: ^timeoff_request_uuid
      }
    end
  end

  describe "TimeoffRequestRejected event" do
    test "invokes Employee with RejectTimeoffRequest command" do
      team_leader = build_aggregate(:team_leader)
      employee = build_aggregate(:employee) |> with_team_leader(team_leader)
      timeoff_request = build_entity(:timeoff_request) |> with_employee(employee)

      event =
        build_event(:timeoff_request_rejected, timeoff_request: timeoff_request)
        |> with_employee(employee)
        |> with_team_leader(team_leader)

      team_leader_uuid = event.team_leader_uuid
      employee_uuid = event.employee_uuid
      timeoff_request_uuid = event.timeoff_request.uuid

      TimeoffEventHandler.handle_event(event, team_leader)

      assert_dispatched Employee, ^employee_uuid, %RejectTimeoffRequest{
        employee_uuid: ^employee_uuid,
        team_leader_uuid: ^team_leader_uuid,
        timeoff_request_uuid: ^timeoff_request_uuid
      }
    end
  end
end
