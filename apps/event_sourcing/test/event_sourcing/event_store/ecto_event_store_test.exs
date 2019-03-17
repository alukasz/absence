defmodule EventSourcing.EventStore.EctoEventStoreTest do
  use EventSourcing.DataCase

  alias EventSourcing.EventStore.EctoEventStore
  alias EventSourcing.Counters.Events.Incremented

  setup do
    stream_id = Ecto.UUID.generate()
    event = %Incremented{uuid: Ecto.UUID.generate(), counter_uuid: stream_id}
    {:ok, stream_id: stream_id, event: event}
  end

  describe "put/2" do
    test "stores event", %{stream_id: stream_id, event: event} do
      assert EctoEventStore.get(stream_id) == []

      EctoEventStore.put(stream_id, event)
      assert EctoEventStore.get(stream_id) == [event]
    end

    # TODO implement events ordering
    @tag :skip
    test "stores multiple events", %{stream_id: stream_id, event: event} do
      assert EctoEventStore.get(stream_id) == []

      event1 = %Incremented{event | uuid: Ecto.UUID.generate()}
      event2 = %Incremented{event | uuid: Ecto.UUID.generate()}
      EctoEventStore.put(stream_id, event1)
      EctoEventStore.put(stream_id, event2)

      assert EctoEventStore.get(stream_id) == [event1, event2]
    end
  end
end
