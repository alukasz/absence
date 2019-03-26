defmodule EventSourcing.EventStore.AgentEventStoreTest do
  use ExUnit.Case

  alias EventSourcing.EventStore.AgentEventStore
  alias EventSourcing.Counters.Events.Incremented

  setup_all do
    start_supervised(AgentEventStore)
    :ok
  end

  setup do
    Agent.update(AgentEventStore, fn _ -> {1, %{}} end)
    uuid = Ecto.UUID.generate()
    event = %Incremented{uuid: Ecto.UUID.generate()}
    {:ok, uuid: uuid, event: event}
  end

  describe "put/2" do
    test "stores event", %{uuid: uuid, event: event} do
      assert AgentEventStore.get(uuid) == []

      AgentEventStore.put(uuid, event)
      assert AgentEventStore.get(uuid) == [event]
    end

    test "stores multiple events", %{uuid: uuid} do
      assert AgentEventStore.get(uuid) == []

      event1 = %Incremented{uuid: Ecto.UUID.generate()}
      event2 = %Incremented{uuid: Ecto.UUID.generate()}
      AgentEventStore.put(uuid, event1)
      AgentEventStore.put(uuid, event2)

      assert AgentEventStore.get(uuid) == [event1, event2]
    end
  end

  describe "next_event_number/0" do
    test "returns 1 for first event" do
      assert AgentEventStore.next_event_number() == 1
    end

    test "returns number of events + 1", %{uuid: uuid} do
      AgentEventStore.next_event_number()
      AgentEventStore.next_event_number()

      assert AgentEventStore.next_event_number() == 3
    end
  end
end
