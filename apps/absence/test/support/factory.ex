defmodule Absence.Factory do
  use ExMachina.Ecto, repo: Absence.Repo

  alias Absence.Accounts
  alias Absence.Absences.Aggregates.Employee
  alias Absence.Absences.Aggregates.TeamLeader
  alias Absence.Absences.TimeoffRequest

  defdelegate build_aggregate(factory_name, attrs \\ []),
    to: Absence.Factory.AggregateFactory,
    as: :build

  defdelegate build_command(factory_name, attrs \\ []),
    to: Absence.Factory.CommandFactory,
    as: :build

  defdelegate string_params_for_command(factory_name, attrs \\ []),
    to: Absence.Factory.CommandFactory,
    as: :string_params_for

  defdelegate build_event(factory_name, attrs \\ []),
    to: Absence.Factory.EventFactory,
    as: :build

  defdelegate build_entity(factory_name, attrs \\ []),
    to: Absence.Factory.EntityFactory,
    as: :build

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

  def with_employee(factory, employee \\ build_aggregate(:employee))

  def with_employee(%{employee_uuid: _} = factory, %Employee{} = employee) do
    %{factory | employee_uuid: employee.uuid}
  end

  def with_employee(%{"employee_uuid" => _} = factory, %Employee{} = employee) do
    %{factory | "employee_uuid" => employee.uuid}
  end

  def with_team_leader(factory, team_leader \\ build_aggregate(:team_leader))

  def with_team_leader(%{team_leader_uuid: _} = factory, %TeamLeader{} = team_leader) do
    %{factory | team_leader_uuid: team_leader.uuid}
  end

  def with_team_leader(%{"team_leader_uuid" => _} = factory, %TeamLeader{} = team_leader) do
    %{factory | "team_leader_uuid" => team_leader.uuid}
  end

  def with_timeoff_request(factory, request \\ build_entity(:timeoff_request))

  def with_timeoff_request(%{timeoff_request_uuid: _} = factory, %TimeoffRequest{} = request) do
    %{factory | timeoff_request_uuid: request.uuid}
  end

  def with_timeoff_request(%{"timeoff_request_uuid" => _} = factory, %TimeoffRequest{} = request) do
    %{factory | "timeoff_request_uuid" => request.uuid}
  end

  def with_uuid(%{} = factory, uuid \\ EventSourcing.UUID.generate()) do
    %{factory | uuid: uuid}
  end
end
