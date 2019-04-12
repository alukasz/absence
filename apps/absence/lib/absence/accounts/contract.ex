defmodule Absence.Accounts.Contract do
  alias Absence.Account.User
  alias Ecto.Changeset

  @callback user_changeset() :: Changeset.t()
  @callback user_changeset(User.t()) :: Changeset.t()

  @callback register(map) :: {:ok, User.t()} | {:error, Changeset.t()}
end
