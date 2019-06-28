defmodule Absence.Absences.TeamLeaders do
  alias Absence.Absences.Employees
  alias Absence.Absences.Aggregates.Employee
  alias Absence.Absences.Aggregates.TeamLeader
  alias Absence.Accounts.User
  alias EventSourcing.Aggregate

  @timeoff_requests_keys [
    :review_timeoff_requests,
    :approved_timeoff_requests,
    :rejected_timeoff_requests
  ]

  def get(%Absence.Accounts.User{} = user) do
    user
    |> Employees.get()
    |> get()
  end

  def get(%Employee{team_leader_aggregate_uuid: nil}), do: nil

  def get(%Employee{team_leader_aggregate_uuid: uuid}) do
    Aggregate.get({TeamLeader, uuid})
  end

  def get_timeoff_requests(%User{} = user) do
    user
    |> get()
    |> Map.take(@timeoff_requests_keys)
    |> Map.values()
    |> List.flatten()
  end
end
