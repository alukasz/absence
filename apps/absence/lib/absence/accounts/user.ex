defmodule Absence.Accounts.User do
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: struct

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :password, :string
    field :password_confirmation, :string, virtual: true
  end

  @params [
    :first_name,
    :last_name,
    :email,
    :password
  ]

  def insert_changeset(params) do
    %__MODULE__{}
    |> cast(params, @params)
    |> validate_required(@params)
    |> unique_constraint(:email)
    |> validate_confirmation(:password, message: "does not match")
    |> hash_password()
  end

  defp hash_password(%{valid?: false} = changeset), do: changeset

  defp hash_password(changeset) do
    password = get_change(changeset, :password)
    hash = Argon2.hash_pwd_salt(password)
    put_change(changeset, :password, hash)
  end
end
