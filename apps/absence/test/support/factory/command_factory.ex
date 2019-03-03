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
end
