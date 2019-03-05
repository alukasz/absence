defmodule Absence.Absences.Aggregates.EmployeeTest do
  use ExUnit.Case, async: true

  import Absence.Factory

  alias Absence.Absences.Aggregates.Employee
  alias Absence.Absences.Events.HoursAdded
  alias Absence.Absences.Events.HoursRemoved

  setup do
    timeoff = build_aggregate(:timeoff)

    {:ok, timeoff: timeoff}
  end

  describe "adding hours" do
    test "AddHours command generates HoursAdded event", %{timeoff: timeoff} do
      command = build_command(:add_hours, hours: 8)

      assert Employee.execute(timeoff, command) == %HoursAdded{
               timeoff_uuid: timeoff.uuid,
               hours: command.hours
             }
    end

    test "HoursAdded events increases hours of aggregate", %{timeoff: timeoff} do
      event = build_event(:hours_added, timeoff_uuid: timeoff.uuid)

      assert Employee.apply(timeoff, event) == %{timeoff | hours: timeoff.hours + event.hours}
    end
  end

  describe "removing hours" do
    test "RemoveHours command generates HoursRemoved event", %{timeoff: timeoff} do
      command = build_command(:remove_hours, hours: 8)

      assert Employee.execute(timeoff, command) == %HoursRemoved{
               timeoff_uuid: timeoff.uuid,
               hours: command.hours
             }
    end

    test "HoursRemoved events decreases hours of aggregate", %{timeoff: timeoff} do
      event = build_event(:hours_removed, timeoff_uuid: timeoff.uuid)

      assert Employee.apply(timeoff, event) == %{timeoff | hours: timeoff.hours - event.hours}
    end
  end
end
