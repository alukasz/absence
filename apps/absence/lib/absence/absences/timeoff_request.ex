defmodule Absence.Absences.TimeOffRequest do
  alias __MODULE__

  defstruct [
    :employee_uuid,
    :start_date,
    :end_date
  ]

  def from_event(event) do
    struct(TimeOffRequest, Map.from_struct(event))
  end
end
