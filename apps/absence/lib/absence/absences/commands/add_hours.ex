defmodule Absence.Absences.Commands.AddHours do
  defstruct [
    :uuid,
    :employee_uuid,
    :hours
  ]
end
