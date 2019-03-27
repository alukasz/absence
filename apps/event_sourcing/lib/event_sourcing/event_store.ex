defmodule EventSourcing.EventStore do
  alias EventSourcing.Aggregate

  @callback start_link(Keyword.t()) :: Supervisor.on_start()
  @callback put(Ecto.UUID.t(), Aggregate.event()) :: :ok
  @callback get(Ecto.UUID.t()) :: [Aggregate.event()]
end
