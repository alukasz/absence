defmodule Absence.Absences.Commands.RequestTimeOff do
  defstruct [
    :uuid,
    :employee_uuid,
    :start_date,
    :end_date
  ]
end
