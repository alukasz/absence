defmodule Absence.Absences.Aggregates.Timeoff do
  @behaviour EventSourcing.Aggregate

  alias __MODULE__
  alias Absence.Absences.Commands.AddHours
  alias Absence.Absences.Events.HoursAdded

  defstruct [
    :uuid,
    hours: 0
  ]

  def execute(%Timeoff{} = timeoff, %AddHours{} = add_hours) do
    %HoursAdded{
      timeoff_uuid: timeoff.uuid,
      hours: add_hours.hours
    }
  end

  def apply(%Timeoff{} = timeoff, %HoursAdded{hours: hours}) do
    %{timeoff | hours: timeoff.hours + hours}
  end
end
