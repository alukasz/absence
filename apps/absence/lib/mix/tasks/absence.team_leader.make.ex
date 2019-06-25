defmodule Mix.Tasks.Absence.TeamLeader.Set do
  @shortdoc "Sets employee's team leader"

  use Mix.Task

  alias Absence.Absences.Commands.SetTeamLeader

  def run([employee_uuid, team_leader_uuid]) do
    %SetTeamLeader{
      employee_uuid: employee_uuid,
      team_leader_uuid: team_leader_uuid
    }
    |> Absence.Dispatcher.dispatch()
  end
end
