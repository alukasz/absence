defmodule Absence.Absences.Employees do
  alias Absence.Absences.Aggregates.Employee
  alias Absence.Absences.Aggregates.TeamLeader
  alias Absence.Accounts.User
  alias EventSourcing.Aggregate

  @timeoff_requests_keys [
    :pending_timeoff_requests,
    :approved_timeoff_requests,
    :rejected_timeoff_requests
  ]

  def get(%User{employee_uuid: employee_uuid}), do: get(employee_uuid)

  def get(uuid) when is_binary(uuid) do
    Aggregate.get({Employee, uuid})
  end

  def get_team_leader(%User{} = user) do
    user
    |> get()
    |> get_team_leader()
  end

  def get_team_leader(%Employee{team_leader_uuid: nil}), do: nil

  def get_team_leader(%Employee{team_leader_uuid: uuid}) do
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
