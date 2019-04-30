defmodule EventSourcing.Aggregate.AggregateServerTest do
  use ExUnit.Case

  alias EventSourcing.Aggregate.AggregateServer
  alias EventSourcing.Counters.Aggregates.Counter
  alias EventSourcing.Counters.Events.Incremented
  alias EventSourcing.UUID
  alias EventSourcing.EventStore.AgentEventStore

  describe "init/1" do
    setup do
      init_opts = [
        aggregate_mod: Counter,
        aggregate_uuid: UUID.generate(),
        event_store: AgentEventStore,
        uuid_generator: UUID
      ]

      {:ok, init_opts: init_opts}
    end

    test "builds aggregate state in handle_continue/2", %{init_opts: init_opts} do
      assert {:ok, _state, {:continue, :build_aggregate}} = AggregateServer.init(init_opts)
    end
  end

  describe "handle_continue(:build_aggregate, _)" do
    setup :state
    @increments 5

    test "fetches aggregates events from store and applies them on start", %{state: state} do
      for _ <- 1..@increments,
          do:
            AgentEventStore.put(state.aggregate_uuid, %Incremented{
              counter_uuid: state.aggregate_uuid
            })

      assert {:noreply, %{aggregate_state: %Counter{value: @increments}}} =
               AggregateServer.handle_continue(:build_aggregate, state)
    end
  end

  defp state(_) do
    uuid = UUID.generate()

    state = %AggregateServer{
      aggregate_mod: Counter,
      aggregate_uuid: uuid,
      store_mod: AgentEventStore,
      uuid_generator_mod: UUID,
      aggregate_state: %Counter{uuid: uuid}
    }

    {:ok, state: state}
  end
end
