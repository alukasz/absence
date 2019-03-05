defmodule Absence.Absences.Aggregates.Employee do
  @behaviour EventSourcing.Aggregate

  alias __MODULE__
  alias Absence.Absences.Commands.AddHours
  alias Absence.Absences.Commands.RemoveHours
  alias Absence.Absences.Events.HoursAdded
  alias Absence.Absences.Events.HoursRemoved

  defstruct [
    :uuid,
    hours: 0
  ]

  def execute(%Employee{} = timeoff, %AddHours{} = add_hours) do
    %HoursAdded{
      timeoff_uuid: timeoff.uuid,
      hours: add_hours.hours
    }
  end

  def execute(%Employee{} = timeoff, %RemoveHours{} = remove_hours) do
    %HoursRemoved{
      timeoff_uuid: timeoff.uuid,
      hours: remove_hours.hours
    }
  end

  def apply(%Employee{} = timeoff, %HoursAdded{hours: hours}) do
    %{timeoff | hours: timeoff.hours + hours}
  end

  def apply(%Employee{} = timeoff, %HoursRemoved{hours: hours}) do
    %{timeoff | hours: timeoff.hours - hours}
  end
end
