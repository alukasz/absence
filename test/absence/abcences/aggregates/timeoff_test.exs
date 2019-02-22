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
    test "adds hours", %{timeoff: timeoff} do
      command = build(:command_add_hours, hours: 8)

      expected_event = %HoursAdded{timeoff_id: timeoff.id, hours: command.hours}
      expected_aggregate = %{timeoff | hours: timeoff.hours + command.hours}

      assert {:ok, ^expected_event, ^expected_aggregate} = Timeoff.apply(command, timeoff)
    end
  end
end
