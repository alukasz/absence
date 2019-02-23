defmodule EventSourcing.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_) do
    children = [
      EventSourcing.AggregateSupervisor,
      {Registry, keys: :unique, name: EventSourcing.AggregateRegistry}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
