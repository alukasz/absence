defmodule Absence.Absences.Aggregates.Timeoff do
  use Absence.Aggregate

  alias __MODULE__
  alias Absence.Absences.Commands.AddHours
  alias Absence.Absences.Events.HoursAdded

  defstruct [
    :id,
    hours: 0
  ]

  def apply(%AddHours{} = add_hours, %Timeoff{} = timeoff) do
    event = %HoursAdded{
      timeoff_id: timeoff.id,
      hours: add_hours.hours
    }

    {:ok, event, %{timeoff | hours: timeoff.hours + add_hours.hours}}
  end
end
