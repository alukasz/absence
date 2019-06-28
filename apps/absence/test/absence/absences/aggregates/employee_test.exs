defmodule Absence.Absences.Aggregates.EmployeeTest do
  use EventSourcing.AggregateCase, async: true

  import Absence.Factory

  alias Absence.Absences.Events.HoursAdded
  alias Absence.Absences.Events.HoursRemoved
  alias Absence.Absences.Events.TimeoffRequested
  alias Absence.Absences.Events.TeamLeaderSet
  alias Absence.Absences.Events.TeamLeaderAwarded
  alias Absence.Absences.Events.TimeoffRequestApproved
  alias Absence.Absences.Events.TimeoffRequestRejected
  alias Absence.Absences.EventHandlers.TimeoffEventHandler

  setup do
    employee = build_aggregate(:employee)
    team_leader = build_aggregate(:team_leader)
    timeoff_request = build_entity(:timeoff_request) |> with_employee(employee) |> with_uuid(nil)

    {:ok, employee: employee, team_leader: team_leader, timeoff_request: timeoff_request}
  end

  describe "adding hours" do
    test "AddHours command generates HoursAdded event", %{employee: employee} do
      command = build_command(:add_hours, hours: 8)

      assert aggregate_execute(employee, command) == %HoursAdded{
               employee_uuid: employee.uuid,
               hours: command.hours
             }
    end

    test "HoursAdded events increases hours of aggregate", %{employee: employee} do
      event = build_event(:hours_added) |> with_employee(employee)

      assert aggregate_apply(employee, event) == %{employee | hours: employee.hours + event.hours}
    end
  end

  describe "removing hours" do
    test "RemoveHours command generates HoursRemoved event", %{employee: employee} do
      command = build_command(:remove_hours, hours: 8)

      assert aggregate_execute(employee, command) == %HoursRemoved{
               employee_uuid: employee.uuid,
               hours: command.hours
             }
    end

    test "HoursRemoved events decreases hours of aggregate", %{employee: employee} do
      event = build_event(:hours_removed) |> with_employee(employee)

      assert aggregate_apply(employee, event) == %{employee | hours: employee.hours - event.hours}
    end
  end

  describe "setting team leader" do
    test "SetTeamLeader command generates TeamLeaderSet event", %{employee: employee} do
      command = build_command(:set_team_leader) |> with_employee(employee) |> with_team_leader()

      assert aggregate_execute(employee, command) == %TeamLeaderSet{
               employee_uuid: command.employee_uuid,
               team_leader_uuid: command.team_leader_uuid
             }
    end

    test "TeamLeaderSet events sets team leader uuid", %{employee: employee} do
      event = build_event(:team_leader_set) |> with_employee(employee) |> with_team_leader()
      team_leader_uuid = event.team_leader_uuid

      assert %{team_leader_uuid: ^team_leader_uuid} = aggregate_apply(employee, event)
    end
  end

  describe "requesting timeoff" do
    test "RequestTimeoff command generates TimeoffRequested event", %{
      employee: employee,
      timeoff_request: timeoff_request
    } do
      command = build_command(:request_timeoff, employee_uuid: employee.uuid)

      assert aggregate_execute(employee, command) == %TimeoffRequested{
               employee_uuid: employee.uuid,
               timeoff_request: timeoff_request
             }
    end

    test "TimeoffRequested event adds TimeoffRequest to pending timeoff requests", %{
      employee: employee,
      timeoff_request: timeoff_request
    } do
      event =
        build_event(:timeoff_requested, timeoff_request: timeoff_request)
        |> with_employee(employee)

      assert %{pending_timeoff_requests: [^timeoff_request]} = aggregate_apply(employee, event)
    end

    test "2 TimeoffRequested events add 2 TimeoffRequest to pending timeoff requests", %{
      employee: employee,
      timeoff_request: timeoff_request
    } do
      event1 =
        build_event(:timeoff_requested, timeoff_request: timeoff_request)
        |> with_employee(employee)

      event2 =
        build_event(:timeoff_requested, timeoff_request: timeoff_request)
        |> with_employee(employee)

      expected_requests = [timeoff_request, timeoff_request]

      employee = aggregate_apply(employee, event1)
      assert %{pending_timeoff_requests: ^expected_requests} = aggregate_apply(employee, event2)
    end

    test "TimeoffRequested event invokes TimeoffEventHandler", %{
      employee: employee,
      timeoff_request: timeoff_request
    } do
      event =
        build_event(:timeoff_requested, timeoff_request: timeoff_request)
        |> with_employee(employee)

      aggregate_apply(employee, event)

      assert event_handler_invoked(TimeoffEventHandler)
    end
  end

  describe "approving timeoff requests" do
    setup :pending_timeoff_request

    test "ApproveTimeoffRequest command generates TimeoffRequestApproved", %{
      employee: employee,
      team_leader: team_leader,
      timeoff_request: timeoff_request
    } do
      command =
        build_command(:approve_timeoff_request)
        |> with_employee(employee)
        |> with_team_leader(team_leader)
        |> with_timeoff_request(timeoff_request)

      assert aggregate_execute(employee, command) == %TimeoffRequestApproved{
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
               aggregate_apply(employee, event)
    end

    test "TimeoffRequestApproved event removes TimeoffRequest from pending timeoff requests", %{
      employee: employee,
      team_leader: team_leader,
      timeoff_request: timeoff_request
    } do
      event =
        build_event(:timeoff_request_approved, timeoff_request: timeoff_request)
        |> with_employee(employee)
        |> with_team_leader(team_leader)

      assert %{pending_timeoff_requests: []} = aggregate_apply(employee, event)
    end
  end

  describe "rejecting timeoff requests" do
    setup :pending_timeoff_request

    test "RejectTimeoffRequest command generates TimeoffRequestRejected", %{
      employee: employee,
      team_leader: team_leader,
      timeoff_request: timeoff_request
    } do
      command =
        build_command(:reject_timeoff_request)
        |> with_employee(employee)
        |> with_team_leader(team_leader)
        |> with_timeoff_request(timeoff_request)

      assert aggregate_execute(employee, command) == %TimeoffRequestRejected{
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

      assert %{rejected_timeoff_requests: [^timeoff_request], approved_timeoff_requests: []} =
               aggregate_apply(employee, event)
    end

    test "TimeoffRequestRejected event removes TimeoffRequest from pending timeoff requests", %{
      employee: employee,
      team_leader: team_leader,
      timeoff_request: timeoff_request
    } do
      event =
        build_event(:timeoff_request_rejected, timeoff_request: timeoff_request)
        |> with_employee(employee)
        |> with_team_leader(team_leader)

      assert %{pending_timeoff_requests: []} = aggregate_apply(employee, event)
    end
  end

  describe "making employee a team leader" do
    test "MakeTeamLeader command generates TeamLeaderAwarded event", %{employee: employee} do
      command = build_command(:make_team_leader) |> with_employee(employee) |> with_team_leader()

      assert aggregate_execute(employee, command) == %TeamLeaderAwarded{
               employee_uuid: command.employee_uuid,
               team_leader_uuid: command.team_leader_uuid
             }
    end

    test "TeamLeaderAwarded events sets team leader aggregate uuid", %{employee: employee} do
      event = build_event(:team_leader_awarded) |> with_employee(employee) |> with_team_leader()
      team_leader_uuid = event.team_leader_uuid

      assert %{team_leader_aggregate_uuid: ^team_leader_uuid} = aggregate_apply(employee, event)
    end
  end

  defp pending_timeoff_request(%{employee: employee, timeoff_request: timeoff_request}) do
    employee = %{employee | pending_timeoff_requests: [timeoff_request]}

    {:ok, employee: employee}
  end
end
