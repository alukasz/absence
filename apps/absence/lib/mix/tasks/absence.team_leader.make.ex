defmodule Mix.Tasks.Absence.TeamLeader.Make do
  @shortdoc "Makes employee a team leader"

  use Mix.Task

  alias Absence.Absences.Commands.MakeTeamLeader

  def run([employee_uuid]) do
    Application.ensure_all_started(:absence)
    uuid = EventSourcing.UUID.generate()

    :ok =
      Absence.Dispatcher.dispatch(%MakeTeamLeader{
        employee_uuid: employee_uuid,
        team_leader_uuid: uuid
      })

    IO.puts("Team leader uuid #{uuid}")
  end
end
