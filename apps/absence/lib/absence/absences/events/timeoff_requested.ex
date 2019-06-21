defmodule Absence.Absences.Events.TimeoffRequested do
  @derive Jason.Encoder

  defstruct [
    :uuid,
    :employee_uuid,
    :timeoff_request
  ]
end
