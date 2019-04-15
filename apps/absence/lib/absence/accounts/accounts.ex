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

  @impl Contract
  def authenticate_email_password(email, password) do
    with %User{} = user <- get_user_by_email(email),
         true <- verify_password(user, password) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  defp verify_password(%User{password: hash}, password) do
    Argon2.verify_pass(password, hash)
  end
end
