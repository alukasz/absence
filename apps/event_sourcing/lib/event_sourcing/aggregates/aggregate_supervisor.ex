defmodule EventSourcing.Aggregates.AggregateSupervisor do
  use DynamicSupervisor

  alias EventSourcing.Aggregates.Aggregate

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def start_aggregate({aggregate_mod, aggregate_uuid}, opts \\ []) do
    aggregate = [aggregate_mod: aggregate_mod, aggregate_uuid: aggregate_uuid]
    child_spec = Aggregate.child_spec(Keyword.merge(aggregate, opts))

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
