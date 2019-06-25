defmodule Absence.Absences.Commands.MakeTeamLeader do
  defstruct [
    :uuid,
    :employee_uuid,
    :team_leader_uuid
  ]
end
