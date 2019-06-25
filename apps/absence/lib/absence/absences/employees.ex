defmodule Absence.Absences.Employees do
  alias Absence.Absences.Aggregates.Employee
  alias Absence.Absences.Aggregates.TeamLeader
  alias Absence.Accounts.User
  alias EventSourcing.Aggregate

  def get(%User{employee_uuid: employee_uuid}), do: get(employee_uuid)

  def get(uuid) when is_binary(uuid) do
    Aggregate.get({Employee, uuid})
  end

  def get_team_leader(%Employee{team_leader_uuid: nil}), do: nil

  def get_team_leader(%Employee{team_leader_uuid: team_leader_uuid}) do
    Aggregate.get({TeamLeader, team_leader_uuid})
  end
end
