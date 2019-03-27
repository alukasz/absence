defmodule EventSourcing.EventStore.EctoEventStoreTest do
  use EventSourcing.DataCase

  import EventSourcing.Factory

  alias EventSourcing.EventStore.EctoEventStore
  alias EventSourcing.Counters.Events.Incremented

  setup do
    {:ok, _} = start_supervised(EctoEventStore)
    stream_id = Ecto.UUID.generate()
    {:ok, stream_id: stream_id}
  end

  describe "put/2" do
    setup %{stream_id: stream_id} do
      event = %Incremented{uuid: Ecto.UUID.generate(), counter_uuid: stream_id}
      {:ok, event: event}
    end

    test "stores event", %{stream_id: stream_id, event: event} do
      assert EctoEventStore.get(stream_id) == []

      EctoEventStore.put(stream_id, event)
      assert EctoEventStore.get(stream_id) == [event]
    end
  end

  describe "get/1" do
    test "returns events in proper order", %{stream_id: stream_id} do
      events =
        for _ <- 1..5 do
          insert(:stored_event, stream_id: stream_id)
        end

      assert EctoEventStore.get(stream_id) == Enum.map(events, &Map.get(&1, :event_data))
    end
  end

  describe "next_event_number/0" do
    test "returns 1 for first event" do
      assert EctoEventStore.next_event_number() == 1
    end

    test "returns max(event_number) + 1", %{stream_id: stream_id} do
      insert(:stored_event, stream_id: stream_id, event_number: 42)

      stop_supervised(EctoEventStore)
      start_supervised(EctoEventStore)

      assert EctoEventStore.next_event_number() == 43
    end
  end
end
