defmodule EventSourcing.Aggregates do
  alias EventSourcing.Aggregates.Aggregate
  alias EventSourcing.Aggregates.AggregateSupervisor
  alias EventSourcing.Context

  @registry EventSourcing.AggregateRegistry

  def execute_command({_mod, _uuid} = aggregate, command, %Context{} = _context) do
    {:ok, pid} = get_aggregate(aggregate)
    Aggregate.execute_command(pid, command)
  end

  defp get_aggregate({_mod, _uuid} = aggregate) do
    case Registry.lookup(@registry, aggregate) do
      [{pid, _}] -> {:ok, pid}
      _ -> AggregateSupervisor.start_aggregate(aggregate)
    end
  end
end
