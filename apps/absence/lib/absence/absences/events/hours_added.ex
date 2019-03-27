defmodule Absence.Absences.Events.HoursAdded do
  @derive Jason.Encoder

  defstruct [
    :uuid,
    :employee_uuid,
    :hours
  ]
end
