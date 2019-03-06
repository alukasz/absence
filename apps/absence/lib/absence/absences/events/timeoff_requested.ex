defmodule Absence.Absences.Events.TimeoffRequested do
  defstruct [
    :uuid,
    :employee_uuid,
    :start_date,
    :end_date
  ]
end
