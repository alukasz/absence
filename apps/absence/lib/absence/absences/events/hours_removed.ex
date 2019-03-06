defmodule Absence.Absences.Events.HoursRemoved do
  defstruct [
    :employee_uuid,
    :hours
  ]
end
