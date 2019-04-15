defmodule Absence.Factory do
  alias Absence.Absences.Aggregates.Employee
  alias Absence.Absences.Aggregates.TeamLeader

  defdelegate build_aggregate(factory_name, attrs \\ []),
    to: Absence.Factory.AggregateFactory,
    as: :build

  defdelegate build_command(factory_name, attrs \\ []),
    to: Absence.Factory.CommandFactory,
    as: :build

  defdelegate build_event(factory_name, attrs \\ []),
    to: Absence.Factory.EventFactory,
    as: :build

  defdelegate build_entity(factory_name, attrs \\ []),
    to: Absence.Factory.EntityFactory,
    as: :build

  def with_employee(%{} = event, %Employee{} = employee) do
    %{event | employee_uuid: employee.uuid}
  end

  def with_team_leader(%{} = event, %TeamLeader{} = team_leader) do
    %{event | team_leader_uuid: team_leader.uuid}
  end
end
