defmodule EventSourcing.AggregateHelper do
  alias EventSourcing.EventStore.AgentEventStore
  alias EventSourcing.Aggregate.AggregateServer

  def start_aggregate(%mod{uuid: uuid} = aggregate_state, opts \\ []) do
    opts = [
      aggregate_mod: mod,
      aggregate_uuid: uuid,
      event_store: Keyword.get(opts, :event_store, AgentEventStore),
      uuid_generator: EventSourcing.UUID,
      aggregate_state: aggregate_state
    ]

    ExUnit.Callbacks.start_supervised!({AggregateServer, opts}, id: uuid)
  end
end
