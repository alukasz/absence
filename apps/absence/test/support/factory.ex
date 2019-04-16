defmodule Absence.Factory do
  use ExMachina.Ecto, repo: Absence.Repo

  alias Absence.Accounts
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

  @password "P@ssw0rd"

  def user_factory do
    %Accounts.User{
      first_name: "Alice",
      last_name: "Doe",
      email: sequence(:user_email, &"test-#{&1}@example.com"),
      password: @password,
      password_confirmation: @password
    }
  end

  def with_hashed_password(user, password \\ nil) do
    hash = Argon2.hash_pwd_salt(password || user.password)
    %{user | password: hash, password_confirmation: nil}
  end
end
