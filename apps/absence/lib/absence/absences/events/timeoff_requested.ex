defmodule Absence.Absences.Events.TimeOffRequested do
  defstruct [
    :employee_uuid,
    :start_date,
    :end_date
  ]
end
