defmodule Absence.Absences.Events.TimeoffRequestRejected do
  defstruct [
    :employee_uuid,
    :team_leader_uuid,
    :timeoff_request
  ]
end
