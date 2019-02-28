defmodule EventSourcing.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      EventSourcing.Aggregates.AggregateSupervisor,
      EventSourcing.EventHandler,
      {Registry, keys: :unique, name: EventSourcing.AggregateRegistry}
    ]

    opts = [strategy: :one_for_one, name: EventSourcing.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
