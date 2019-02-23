defmodule Absence.Absences.Aggregates.Timeoff do
  use EventSourcing.Aggregate

  alias __MODULE__
  alias Absence.Absences.Commands.AddHours
  alias Absence.Absences.Events.HoursAdded

  defstruct [
    :id,
    hours: 0
  ]

  def execute(%Timeoff{} = timeoff, %AddHours{} = add_hours) do
    %HoursAdded{
      timeoff_id: timeoff.id,
      hours: add_hours.hours
    }
  end

  def apply(%Timeoff{} = timeoff, %HoursAdded{hours: hours}) do
    %{timeoff | hours: timeoff.hours + hours}
  end
end
