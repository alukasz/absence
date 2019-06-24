defmodule EventSourcing.Factory do
  use ExMachina.Ecto, repo: EventSourcing.EventStore.Repo

  alias EventSourcing.EventStore.Encoder
  alias EventSourcing.EventStore.StoredEvent
  alias EventSourcing.Counters.Events.Incremented

  def stored_event_factory do
    event_id = EventSourcing.UUID.generate()

    %StoredEvent{
      event_id: event_id,
      stream_id: EventSourcing.UUID.generate(),
      event_name: Atom.to_string(Incremented),
      event_data: Encoder.encode(%Incremented{uuid: event_id}),
      event_number: sequence(:event_number, & &1)
    }
  end
end
