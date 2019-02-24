defmodule Absence.Absences.Aggregates.TimeoffTest do
  use ExUnit.Case, async: true

  import Absence.Factory

  alias Absence.Absences.Aggregates.Timeoff
  alias Absence.Absences.Events.HoursAdded

  setup do
    timeoff = build(:aggregate_timeoff)

    {:ok, timeoff: timeoff}
  end

  describe "adding hours" do
    test "AddHours command generates HoursAdded event", %{timeoff: timeoff} do
      command = build(:command_add_hours, hours: 8)

      assert Timeoff.execute(timeoff, command) == %HoursAdded{
               timeoff_uuid: timeoff.uuid,
               hours: command.hours
             }
    end

    test "HoursAdded events increases hours of aggregate", %{timeoff: timeoff} do
      event = build(:event_hours_added, timeoff_uuid: timeoff.uuid)

      assert Timeoff.apply(timeoff, event) == %{timeoff | hours: timeoff.hours + event.hours}
    end
  end
end
