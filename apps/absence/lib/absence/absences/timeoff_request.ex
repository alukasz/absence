defmodule Absence.Absences.TimeoffRequest do
  alias __MODULE__

  defstruct [
    :uuid,
    :employee_uuid,
    :start_date,
    :end_date
  ]

  def from_event(event) do
    TimeoffRequest
    |> struct(Map.from_struct(event))
    |> Map.put(:uuid, EventSourcing.UUID.generate())
  end
end
