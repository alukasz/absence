defmodule Mix.Tasks.Absence.TeamLeader.Set do
  @shortdoc "Sets employee's team leader"

  use Mix.Task

  alias Absence.Absences.Commands.SetTeamLeader

  def run([employee_uuid, team_leader_uuid]) do
    Application.ensure_all_started(:absence)

    :ok =
      Absence.Dispatcher.dispatch(%SetTeamLeader{
        employee_uuid: employee_uuid,
        team_leader_uuid: team_leader_uuid
      })
  end
end
