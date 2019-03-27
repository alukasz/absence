defmodule EventSourcing.Application do
  @moduledoc false

  use Application

  @event_store Application.get_env(:event_sourcing, :event_store)

  def start(_type, _args) do
    children = [
      EventSourcing.Aggregate.AggregateSupervisor,
      EventSourcing.EventHandler,
      EventSourcing.EventStore.Repo,
      @event_store,
      {Registry, keys: :unique, name: EventSourcing.AggregateRegistry}
    ]

    opts = [strategy: :one_for_one, name: EventSourcing.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
