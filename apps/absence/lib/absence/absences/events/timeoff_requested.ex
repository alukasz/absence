defmodule Absence.Absences.Events.TimeoffRequested do
  @derive Jason.Encoder

  defstruct [
    :uuid,
    :employee_uuid,
    :start_date,
    :end_date
  ]
end
