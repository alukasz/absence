defmodule Absence.Absences.TimeoffRequest do
  alias __MODULE__

  @uuid_generator Application.get_env(:event_sourcing, :uuid_generator)

  @type t :: struct()

  defstruct [
    :uuid,
    :employee_uuid,
    :start_date,
    :end_date,
    :status
  ]

  def from_event(event, status \\ :pending) do
    TimeoffRequest
    |> struct(Map.from_struct(event))
    |> Map.put(:uuid, @uuid_generator.generate())
    |> Map.put(:status, status)
  end
end
