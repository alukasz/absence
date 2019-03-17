defmodule Absence.Absences.Events.HoursRemoved do
  @derive Jason.Encoder

  defstruct [
    :uuid,
    :employee_uuid,
    :hours
  ]
end
