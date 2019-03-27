defmodule Absence.Absences.Aggregates.EmployeeTest do
  use ExUnit.Case, async: true

  import Absence.Factory

  alias Absence.Absences.Aggregates.Employee
  alias Absence.Absences.Events.HoursAdded
  alias Absence.Absences.Events.HoursRemoved
  alias Absence.Absences.Events.TimeoffRequested
  alias Absence.Absences.TimeoffRequest

  setup do
    employee = build_aggregate(:employee)

    {:ok, employee: employee}
  end

  describe "adding hours" do
    test "AddHours command generates HoursAdded event", %{employee: employee} do
      command = build_command(:add_hours, hours: 8)

      assert Employee.execute(employee, command) == %HoursAdded{
               employee_uuid: employee.uuid,
               hours: command.hours
             }
    end

    test "HoursAdded events increases hours of aggregate", %{employee: employee} do
      event = build_event(:hours_added, employee_uuid: employee.uuid)

      assert Employee.apply(employee, event) == %{employee | hours: employee.hours + event.hours}
    end
  end

  describe "removing hours" do
    test "RemoveHours command generates HoursRemoved event", %{employee: employee} do
      command = build_command(:remove_hours, hours: 8)

      assert Employee.execute(employee, command) == %HoursRemoved{
               employee_uuid: employee.uuid,
               hours: command.hours
             }
    end

    test "HoursRemoved events decreases hours of aggregate", %{employee: employee} do
      event = build_event(:hours_removed, employee_uuid: employee.uuid)

      assert Employee.apply(employee, event) == %{employee | hours: employee.hours - event.hours}
    end
  end

  describe "requesting timeoff" do
    test "RequestTimeoff command generates TimeoffRequestedEvent", %{employee: employee} do
      command = build_command(:request_timeoff)

      assert Employee.execute(employee, command) == %TimeoffRequested{
               employee_uuid: employee.uuid,
               start_date: command.start_date,
               end_date: command.end_date
             }
    end

    test "TimeoffRequested event adds TimeoffRequest to pending timeoff requests", %{
      employee: employee
    } do
      event = build_event(:timeoff_requested, employee_uuid: employee.uuid)

      expected_request = %TimeoffRequest{
        employee_uuid: employee.uuid,
        start_date: event.start_date,
        end_date: event.end_date
      }

      assert %{pending_timeoff_requests: [actual_request]} = Employee.apply(employee, event)
      assert expected_request == actual_request
    end

    test "2 TimeoffRequested events add 2 TimeoffRequest to pending timeoff requests", %{
      employee: employee
    } do
      event1 = build_event(:timeoff_requested, employee_uuid: employee.uuid)
      event2 = build_event(:timeoff_requested, employee_uuid: employee.uuid)

      expected_requests = [
        %TimeoffRequest{
          employee_uuid: employee.uuid,
          start_date: event2.start_date,
          end_date: event2.end_date
        },
        %TimeoffRequest{
          employee_uuid: employee.uuid,
          start_date: event1.start_date,
          end_date: event1.end_date
        }
      ]

      employee = Employee.apply(employee, event1)
      assert %{pending_timeoff_requests: actual_requests} = Employee.apply(employee, event2)
      assert expected_requests == actual_requests
    end
  end
end
