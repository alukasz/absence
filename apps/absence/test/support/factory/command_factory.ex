defmodule Absence.Factory.CommandFactory do
  use ExMachina

  alias Absence.Absences.Commands

  def add_hours_factory do
    %Commands.AddHours{
      hours: 8
    }
  end

  def remove_hours_factory do
    %Commands.RemoveHours{
      hours: 8
    }
  end

  def request_timeoff_factory do
    %Commands.RequestTimeOff{
      start_date: ~D[2019-01-01],
      end_date: ~D[2019-01-10]
    }
  end
end
