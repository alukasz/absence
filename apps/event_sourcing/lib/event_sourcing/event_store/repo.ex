defmodule EventSourcing.EventStore.Repo do
  use Ecto.Repo,
    otp_app: :event_sourcing,
    adapter: Ecto.Adapters.Postgres
end
