defmodule Absence.Absences.Commands.AddHours do
  defstruct [
    :uuid,
    :timeoff_uuid,
    :hours
  ]
end
