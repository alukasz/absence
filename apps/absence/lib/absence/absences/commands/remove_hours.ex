defmodule Absence.Absences.Commands.RemoveHours do
  defstruct [
    :uuid,
    :employee_uuid,
    :hours
  ]
end
