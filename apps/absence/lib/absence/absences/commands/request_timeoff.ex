defmodule Absence.Absences.Commands.RequestTimeoff do
  defstruct [
    :uuid,
    :employee_uuid,
    :start_date,
    :end_date
  ]
end
