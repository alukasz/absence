defmodule EventSourcing.EventStore.StoredEvent do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:event_id, :binary_id, autogenerate: false}
  @event_store Application.get_env(:event_sourcing, :event_store)

  schema "events" do
    field(:stream_id, :binary_id)
    field(:event_number, :integer)
    field(:event_name, :string)
    field(:event_data, :map)
  end

  @fields [
    :event_id,
    :stream_id,
    :event_name,
    :event_data
  ]

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> put_event_number()
  end

  defp put_event_number(%{valid?: false} = changeset), do: changeset

  defp put_event_number(changeset) do
    put_change(changeset, :event_number, @event_store.next_event_number())
  end
end
