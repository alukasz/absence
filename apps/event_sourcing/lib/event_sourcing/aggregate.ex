defmodule EventSourcing.Aggregate do
  alias EventSourcing.Aggregate.AggregateSupervisor

  @registry EventSourcing.AggregateRegistry

  @type struct_with_uuid :: %{
          :__struct__ => module,
          :uuid => Ecto.UUID.t(),
          optional(atom) => any
        }
  @type aggregate :: struct_with_uuid
  @type event :: struct_with_uuid
  @type command :: struct_with_uuid

  @callback execute(aggregate, command) :: event

  @callback apply(aggregate, event) :: aggregate

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
