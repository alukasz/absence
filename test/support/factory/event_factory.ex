defmodule Absence.Factory.EventFactory do
  use ExMachina

  alias Absence.Absences.Events

  def hours_added_factory do
    %Events.HoursAdded{
      hours: 8
    }
  end
end
