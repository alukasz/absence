defmodule EventSourcing.Aggregates.AggregateSupervisor do
  use DynamicSupervisor

  alias EventSourcing.Aggregates.Aggregate

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def start_aggregate({_mod, _uuid} = aggregate, opts) do
    child_spec = Aggregate.child_spec({aggregate, opts})

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
