defmodule EventSourcing.EventStore.EctoEventStore do
  @behaviour EventSourcing.EventStore

  import Ecto.Query

  alias EventSourcing.EventStore.Repo
  alias EventSourcing.EventStore.StoredEvent

  def put(stream_id, %event_name{uuid: event_id} = event) do
    attrs = %{
      event_id: event_id,
      stream_id: stream_id,
      event_name: Atom.to_string(event_name),
      event_data: event
    }

    %StoredEvent{}
    |> StoredEvent.changeset(attrs)
    |> Repo.insert()
  end

  def get(stream_id) do
    from(e in StoredEvent)
    |> where([e], e.stream_id == ^stream_id)
    |> Repo.all()
    |> decode_events()
  end

  def decode_events([]), do: []

  def decode_events(stored_events) do
    Enum.map(stored_events, fn %{event_name: event_name, event_data: event_data} ->
      event_mod = String.to_existing_atom(event_name)

      event_data =
        Enum.map(event_data, fn {key, value} ->
          {String.to_existing_atom(key), value}
        end)

      struct(event_mod, event_data)
    end)
  end
end