defmodule Absence.Accounts do
  alias Absence.Repo
  alias Absence.Accounts.User
  alias Ecto.Changeset

  def user_changeset do
    Changeset.change(%User{})
  end

  def register(user_params) do
    %User{}
    |> User.insert_changeset(user_params)
    |> Repo.insert()
  end
end
