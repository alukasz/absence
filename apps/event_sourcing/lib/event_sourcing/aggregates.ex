defmodule EventSourcing.Aggregates do
  alias EventSourcing.Aggregates.AggregateSupervisor

  @registry EventSourcing.AggregateRegistry

  def execute_command({_mod, _uuid} = aggregate, command, context) do
    {:ok, pid} = get_aggregate(aggregate)
    GenServer.call(pid, {:execute, command, context})
  end

  defp get_aggregate({_mod, _uuid} = aggregate) do
    case Registry.lookup(@registry, aggregate) do
      [{pid, _}] -> {:ok, pid}
      _ -> AggregateSupervisor.start_aggregate(aggregate)
    end
  end
end
