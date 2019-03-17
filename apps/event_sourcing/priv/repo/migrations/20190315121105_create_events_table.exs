defmodule EventSourcing.EventStore.Repo.Migrations.CreateEventsTable do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :event_id, :binary_id, primary_key: true
      add :stream_id, :binary_id
      add :event_name, :string
      add :event_data, :map
    end

    create index(:events, :stream_id)
  end
end
