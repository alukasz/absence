defmodule Absence.Absences.Aggregates.EmployeeTest do
  use ExUnit.Case, async: true

  import Absence.Factory

  alias Absence.Absences.Aggregates.Employee
  alias Absence.Absences.Events.HoursAdded
  alias Absence.Absences.Events.HoursRemoved
  alias Absence.Absences.Events.TimeOffRequested
  alias Absence.Absences.TimeOffRequest

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
    test "RequestTimeOff command generates TimeOffRequestedEvent", %{employee: employee} do
      command = build_command(:request_timeoff)

      assert Employee.execute(employee, command) == %TimeOffRequested{
               employee_uuid: employee.uuid,
               start_date: command.start_date,
               end_date: command.end_date
             }
    end

    test "TimeOffRequested event adds TimeOffRequest to pending timeoff requests", %{
      employee: employee
    } do
      event = build_event(:timeoff_requested, employee_uuid: employee.uuid)

      assert Employee.apply(employee, event) == %{
               employee
               | pending_timeoff_requests: [
                   %TimeOffRequest{
                     employee_uuid: employee.uuid,
                     start_date: event.start_date,
                     end_date: event.end_date
                   }
                 ]
             }
    end

    test "2 TimeOffRequested events add 2 TimeOffRequest to pending timeoff requests", %{
      employee: employee
    } do
      event1 = build_event(:timeoff_requested, employee_uuid: employee.uuid)
      event2 = build_event(:timeoff_requested, employee_uuid: employee.uuid)

      employee = Employee.apply(employee, event1)

      assert Employee.apply(employee, event2) == %{
               employee
               | pending_timeoff_requests: [
                   %TimeOffRequest{
                     employee_uuid: employee.uuid,
                     start_date: event2.start_date,
                     end_date: event2.end_date
                   },
                   %TimeOffRequest{
                     employee_uuid: employee.uuid,
                     start_date: event1.start_date,
                     end_date: event1.end_date
                   }
                 ]
             }
    end
  end
end
