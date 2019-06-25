defmodule Absence.Absences.Events.TeamLeaderSet do
  defstruct [
    :uuid,
    :employee_uuid,
    :team_leader_uuid
  ]
end
