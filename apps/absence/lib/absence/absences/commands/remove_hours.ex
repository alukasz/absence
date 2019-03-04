defmodule Absence.Absences.Commands.RemoveHours do
  defstruct [
    :uuid,
    :timeoff_uuid,
    :hours
  ]
end
