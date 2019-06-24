defmodule EventSourcing.EventStore.EctoEventStore do
  @behaviour EventSourcing.EventStore

  use Agent

  import Ecto.Query

  alias EventSourcing.EventStore.Encoder
  alias EventSourcing.EventStore.Repo
  alias EventSourcing.EventStore.StoredEvent

  def start_link(_) do
    init = fn ->
      from(e in StoredEvent, select: max(e.event_number))
      |> Repo.one()
      |> case do
        nil -> 0
        event_number -> event_number
      end
    end

    Agent.start_link(init, name: __MODULE__)
  end

  def put(stream_id, %event_name{uuid: event_id} = event) do
    attrs = %{
      event_id: event_id,
      stream_id: stream_id,
      event_name: Atom.to_string(event_name),
      event_data: Encoder.encode(event)
    }

    %StoredEvent{}
    |> StoredEvent.changeset(attrs)
    |> Repo.insert()
  end

  def get(stream_id) do
    from(e in StoredEvent)
    |> where([e], e.stream_id == ^stream_id)
    |> order_by([e], asc: e.event_number)
    |> Repo.all()
    |> decode_events()
  end

  def next_event_number do
    Agent.get_and_update(__MODULE__, fn event_number -> {event_number + 1, event_number + 1} end)
  end

  def decode_events(stored_events) do
    Enum.map(stored_events, &Encoder.decode(&1.event_data))
  end
end
