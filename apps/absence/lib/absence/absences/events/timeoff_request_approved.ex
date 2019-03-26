defmodule Absence.Absences.Events.TimeoffRequestApproved do
  defstruct [
    :employee_uuid,
    :team_leader_uuid,
    :timeoff_request
  ]
end
