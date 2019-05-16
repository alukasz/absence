defmodule Absence.Absences.Contract do
  alias Ecto.Changeset
  alias EventSourcing.UUID

  @callback request_timeoff() :: Changeset.t()

  @callback request_timeoff(UUID.t(), map()) :: :ok | {:error, Changeset.t()}
end
