defmodule EventSourcing.Aggregates do
  alias EventSourcing.Aggregates.Aggregate
  alias EventSourcing.Aggregates.AggregateSupervisor

  @registry EventSourcing.AggregateRegistry

  def execute_command({_mod, _uuid} = aggregate, command, opts \\ []) do
    {:ok, pid} = get_aggregate(aggregate, opts)
    Aggregate.execute_command(pid, command)
  end

  defp get_aggregate({_mod, _uuid} = aggregate, opts) do
    case Registry.lookup(@registry, aggregate) do
      [{pid, _}] -> {:ok, pid}
      _ -> AggregateSupervisor.start_aggregate(aggregate, opts)
    end
  end
end
