defmodule Absence.Factory do
  use ExMachina.Ecto, repo: Absence.Repo

  alias Absence.Accounts

  defdelegate build_aggregate(factory_name, attrs \\ []),
    to: Absence.Factory.AggregateFactory,
    as: :build

  defdelegate build_command(factory_name, attrs \\ []),
    to: Absence.Factory.CommandFactory,
    as: :build

  defdelegate build_event(factory_name, attrs \\ []),
    to: Absence.Factory.EventFactory,
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
end
