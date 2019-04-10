defmodule Absence.Accounts do
  @behaviour Absence.Accounts.Contract

  alias Absence.Repo
  alias Absence.Accounts.Contract
  alias Absence.Accounts.User
  alias Ecto.Changeset

  @impl Contract
  def user_changeset(user \\ %User{}) do
    Changeset.change(user)
  end

  @impl Contract
  def register(user_params) do
    user_params
    |> User.insert_changeset()
    |> Repo.insert()
  end
end
