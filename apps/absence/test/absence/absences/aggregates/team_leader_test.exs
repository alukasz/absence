defmodule Absence.Absences.Aggregates.TeamLeaderTest do
  use ExUnit.Case, async: true

  import Absence.Factory

  alias Absence.Absences.Aggregates.TeamLeader
  alias Absence.Absences.Events.TimeoffRequestApproved
  alias Absence.Absences.Events.TimeoffRequestRejected
  alias Absence.Absences.TimeoffRequest

  setup do
    team_leader = build_aggregate(:team_leader)
    employee = build_aggregate(:employee)
    event = build_event(:timeoff_requested, employee_uuid: employee.uuid)
    timeoff_request = TimeoffRequest.from_event(event)

    employee = %{
      employee
      | pending_timeoff_requests: [timeoff_request | employee.pending_timeoff_requests]
    }

    {:ok, employee: employee, team_leader: team_leader, timeoff_request: timeoff_request}
  end

  describe "approving timeoff requests" do
    test "ApproveTimeoffRequest approves time off for specified employee", %{
      employee: employee,
      team_leader: team_leader,
      timeoff_request: timeoff_request
    } do
      command =
        build_command(:approve_timeoff_request,
          employee_uuid: employee.uuid,
          team_leader_uuid: team_leader.uuid,
          timeoff_request: timeoff_request
        )

      assert TeamLeader.execute(team_leader, command) == %TimeoffRequestApproved{
               employee_uuid: employee.uuid,
               team_leader_uuid: team_leader.uuid,
               timeoff_request: timeoff_request
             }
    end
  end

  describe "rejecting timeoff requests" do
    test "RejectTimeoffRequest rejects time off for specified employee", %{
      employee: employee,
      team_leader: team_leader,
      timeoff_request: timeoff_request
    } do
      command =
        build_command(:reject_timeoff_request,
          employee_uuid: employee.uuid,
          team_leader_uuid: team_leader.uuid,
          timeoff_request: timeoff_request
        )

      assert TeamLeader.execute(team_leader, command) == %TimeoffRequestRejected{
               employee_uuid: employee.uuid,
               team_leader_uuid: team_leader.uuid,
               timeoff_request: timeoff_request
             }
    end
  end
end
