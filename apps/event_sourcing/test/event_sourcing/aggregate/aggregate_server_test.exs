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

    test "if aggregate state doesn't already exists fetches events from store and applies them",
         %{state: state} do
      uuid = state.aggregate_uuid

      for _ <- 1..@increments do
        AgentEventStore.put(uuid, %Incremented{counter_uuid: uuid})
      end

      assert {:noreply, %{aggregate_state: state}} =
               AggregateServer.handle_continue(:build_aggregate, state)

      assert %Counter{uuid: ^uuid, value: @increments} = state
    end

    test "uses already existing aggregate state", %{state: state} do
      uuid = state.aggregate_uuid

      for _ <- 1..@increments do
        AgentEventStore.put(uuid, %Incremented{counter_uuid: uuid})
      end

      state = %{state | aggregate_state: %Counter{uuid: :uuid, value: 42}}

      assert {:noreply, %{aggregate_state: state}} =
               AggregateServer.handle_continue(:build_aggregate, state)

      assert %Counter{uuid: :uuid, value: 42} = state
      refute state.uuid == uuid
    end
  end

  defp state(_) do
    uuid = UUID.generate()

    state = %AggregateServer{
      aggregate_mod: Counter,
      aggregate_uuid: uuid,
      store_mod: AgentEventStore,
      uuid_generator_mod: UUID,
      aggregate_state: nil
    }

    {:ok, state: state}
  end
end
