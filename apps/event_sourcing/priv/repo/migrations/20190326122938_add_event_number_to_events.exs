defmodule EventSourcing.EventStore.Repo.Migrations.AddEventNumberToEvents do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :event_number, :integer
    end

    create unique_index(:events, :event_number)
  end
end
