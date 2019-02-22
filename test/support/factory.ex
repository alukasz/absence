defmodule Absence.Factory do
  use ExMachina

  alias Absence.Absences.Aggregates.Timeoff
  alias Absence.Absences.Commands.AddHours
  alias Absence.Absences.Events.HoursAdded

  def aggregate_timeoff_factory do
    %Timeoff{
      id: :rand.uniform(10000),
      hours: 80
    }
  end

  def event_hours_added_factory do
    %HoursAdded{
      hours: 8
    }
  end

  def command_add_hours_factory do
    %AddHours{
      hours: 8
    }
  end
end
