defmodule EventSourcing.EventStore do
  alias EventSourcing.Aggregate

  @callback put(EventSourcing.UUID.t(), Aggregate.event()) :: :ok
  @callback get(EventSourcing.UUID.t()) :: [Aggregate.event()]
end
