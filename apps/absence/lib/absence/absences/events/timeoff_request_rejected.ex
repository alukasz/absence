defmodule Absence.Absences.Events.TimeoffRequestRejected do
  @derive Jason.Encoder

  defstruct [
    :uuid,
    :employee_uuid,
    :team_leader_uuid,
    :timeoff_request
  ]
end
