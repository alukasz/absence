defmodule EventSourcing.Aggregate do
  alias EventSourcing.Aggregate.AggregateSupervisor
  alias EventSourcing.UUID

  @registry EventSourcing.AggregateRegistry

  @type struct_with_uuid :: %{
          :__struct__ => module,
          :uuid => EventSourcing.UUID.t(),
          optional(atom) => any
        }
  @type aggregate :: struct_with_uuid
  @type event :: struct_with_uuid
  @type command :: struct_with_uuid

  @callback execute(aggregate, command) :: event

  @callback apply(aggregate, event) :: aggregate

  def execute_command({_mod, _uuid} = aggregate, command, context) do
    {:ok, pid} = get_aggregate(aggregate)
    {command, context} = prepare_command(command, context)
    GenServer.call(pid, {:execute, command, context})
  end

  def get({_mod, _uuid} = aggregate) do
    {:ok, pid} = get_aggregate(aggregate)
    GenServer.call(pid, :get)
  end

  defp get_aggregate({_mod, _uuid} = aggregate) do
    case Registry.lookup(@registry, aggregate) do
      [{pid, _}] -> {:ok, pid}
      _ -> AggregateSupervisor.start_aggregate(aggregate)
    end
  end

  defp prepare_command(%{uuid: nil} = command, context) do
    prepare_command(%{command | uuid: UUID.generate()}, context)
  end

  defp prepare_command(%{uuid: uuid} = command, context) do
    {command, %{context | command_uuid: uuid}}
  end
end
