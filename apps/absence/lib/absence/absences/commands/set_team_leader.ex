defmodule Absence.Absences.Commands.SetTeamLeader do
  defstruct [
    :uuid,
    :employee_uuid,
    :team_leader_uuid
  ]
end
