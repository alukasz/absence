defmodule EventSourcing.EventStore do
  alias EventSourcing.Aggregate

  @callback put(Ecto.UUID.t(), Aggregate.event()) :: :ok
  @callback get(Ecto.UUID.t()) :: [Aggregate.event()]
end
