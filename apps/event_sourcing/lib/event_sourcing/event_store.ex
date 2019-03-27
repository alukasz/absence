defmodule EventSourcing.EventStore do
  alias EventSourcing.Aggregate

  @callback start_link(Keyword.t()) :: Supervisor.on_start()
  @callback put(EventSourcing.UUID.t(), Aggregate.event()) :: :ok
  @callback get(EventSourcing.UUID.t()) :: [Aggregate.event()]
end
