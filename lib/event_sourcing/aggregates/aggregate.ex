defmodule EventSourcing.Aggregates.Aggregate do
  use GenServer

  alias EventSourcing.EventStore.AgentEventStore

  @registry EventSourcing.AggregateRegistry

  def start_link({_mod, _uuid} = aggregate) do
    GenServer.start_link(__MODULE__, aggregate, name: name(aggregate))
  end

  def execute_command(aggregate_pid, command) when is_pid(aggregate_pid) do
    GenServer.call(aggregate_pid, {:execute_command, command})
  end

  def name({_mod, _uuid} = aggregate) do
    {:via, Registry, {@registry, aggregate}}
  end

  def init({aggregate_mod, aggregate_uuid}) do
    aggregate = apply(aggregate_mod, :__struct__, [[uuid: aggregate_uuid]])

    state = %{
      aggregate_mod: aggregate_mod,
      aggregate_uuid: aggregate_uuid,
      aggregate: aggregate
    }

    {:ok, state}
  end

  def handle_call({:execute_command, command}, _from, state) do
    %{aggregate_mod: aggregate_mod, aggregate: aggregate} = state
    event = aggregate_mod.execute(aggregate, command)
    aggregate = aggregate_mod.apply(aggregate, event)
    store_event(aggregate, event)

    {:reply, {event, aggregate}, %{state | aggregate: aggregate}}
  end

  defp store_event(%{uuid: uuid} = _aggregate, event) do
    AgentEventStore.put(uuid, event)
  end
end
