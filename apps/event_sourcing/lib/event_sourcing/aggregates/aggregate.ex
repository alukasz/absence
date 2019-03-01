defmodule EventSourcing.Aggregates.Aggregate do
  use GenServer

  alias EventSourcing.EventHandler
  alias EventSourcing.EventStore.AgentEventStore

  @registry EventSourcing.AggregateRegistry

  def start_link({{_mod, _uuid} = aggregate, opts}) do
    GenServer.start_link(__MODULE__, {aggregate, opts}, name: name(aggregate))
  end

  def execute_command(aggregate_pid, command) when is_pid(aggregate_pid) do
    GenServer.call(aggregate_pid, {:execute_command, command})
  end

  def name({_mod, _uuid} = aggregate) do
    {:via, Registry, {@registry, aggregate}}
  end

  def init({{aggregate_mod, aggregate_uuid}, opts}) do
    aggregate = apply(aggregate_mod, :__struct__, [[uuid: aggregate_uuid]])

    state = %{
      aggregate_mod: aggregate_mod,
      aggregate_uuid: aggregate_uuid,
      aggregate: aggregate,
      store_mod: Keyword.get(opts, :store, AgentEventStore)
    }

    {:ok, state}
  end

  def handle_call({:execute_command, command}, _from, state) do
    %{aggregate_mod: aggregate_mod, aggregate: aggregate, store_mod: store} = state
    event = aggregate_mod.execute(aggregate, command)
    aggregate = aggregate_mod.apply(aggregate, event)
    store_event(store, aggregate, event)
    EventHandler.dispatch(event, aggregate)

    {:reply, {event, aggregate}, %{state | aggregate: aggregate}}
  end

  defp store_event(store, %{uuid: uuid} = _aggregate, event) do
    store.put(uuid, event)
  end
end
