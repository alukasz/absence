defmodule Absence.Absences.TimeoffRequest do
  alias __MODULE__

  @uuid_generator Application.get_env(:event_sourcing, :uuid_generator)

  defstruct [
    :uuid,
    :employee_uuid,
    :start_date,
    :end_date
  ]

  def from_event(event) do
    TimeoffRequest
    |> struct(Map.from_struct(event))
    |> Map.put(:uuid, @uuid_generator.generate())
  end
end
