defmodule Absence.Absences.TeamLeaders do
  alias Absence.Absences.Employees
  alias Absence.Absences.Aggregates.Employee
  alias Absence.Absences.Aggregates.TeamLeader
  alias EventSourcing.Aggregate

  def get(%Employee{team_leader_aggregate_uuid: nil}), do: nil

  def get(%Employee{team_leader_aggregate_uuid: uuid}) do
    Aggregate.get({TeamLeader, uuid})
  end

  def get(%Absence.Accounts.User{} = user) do
    user
    |> Employees.get()
    |> get()
  end
end
