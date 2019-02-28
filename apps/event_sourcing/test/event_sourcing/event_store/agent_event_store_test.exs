defmodule EventSourcing.EventStore.AgentEventStoreTest do
  use ExUnit.Case

  alias EventSourcing.EventStore.AgentEventStore
  alias EventSourcing.Support.Counters.Events.Incremented

  setup do
    start_supervised(AgentEventStore)
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
end
