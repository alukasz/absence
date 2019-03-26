defmodule EventSourcing.EventStore.EctoEventStoreTest do
  use EventSourcing.DataCase

  alias EventSourcing.EventStore.EctoEventStore
  alias EventSourcing.EventStore.StoredEvent
  alias EventSourcing.Counters.Events.Incremented

  setup do
    {:ok, _} = start_supervised(EctoEventStore)
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
  describe "next_event_number/0" do
    test "returns 1 for first event" do
      assert EctoEventStore.next_event_number() == 1
    end

    test "returns max(event_number) + 1", %{stream_id: stream_id, event: event} do
      %StoredEvent{
        event_id: event.uuid,
        stream_id: stream_id,
        event_name: "event",
        event_data: event,
        event_number: 42
      }
      |> Repo.insert!()

      stop_supervised(EctoEventStore)
      start_supervised(EctoEventStore)

      assert EctoEventStore.next_event_number() == 43
    end
  end
end
