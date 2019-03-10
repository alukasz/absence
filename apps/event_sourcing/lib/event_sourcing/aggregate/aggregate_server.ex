defmodule EventSourcing.Aggregate.AggregateServer do
  use GenServer

  alias EventSourcing.EventHandler
  alias Ecto.UUID

  defstruct [
    :aggregate_uuid,
    :aggregate_mod,
    :aggregate_state,
    :store_mod
  ]

  @registry EventSourcing.AggregateRegistry

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: name(opts))
  end

  def name(opts) when is_list(opts) do
    [aggregate_mod: mod, aggregate_uuid: uuid] =
      Keyword.take(opts, [:aggregate_mod, :aggregate_uuid])

    name(mod, uuid)
  end

  def name(aggregate_mod, aggregate_uuid) do
    {:via, Registry, {@registry, {aggregate_mod, aggregate_uuid}}}
  end

  def init(opts) do
    state = %__MODULE__{
      aggregate_uuid: Keyword.fetch!(opts, :aggregate_uuid),
      aggregate_mod: Keyword.fetch!(opts, :aggregate_mod),
      store_mod: Keyword.get(opts, :event_store, EventSourcing.EventStore.AgentEventStore)
    }

    {:ok, state, {:continue, :build_aggregate}}
  end

  def handle_continue(:build_aggregate, state) do
    {:noreply, build_aggregate(state)}
  end

  def handle_call({:execute, command, context}, _from, state) do
    {result, state} = execute_command(state, command, context)

    {:reply, result, state}
  end

  defp build_aggregate(state) do
    %{aggregate_mod: aggregate_mod, aggregate_uuid: aggregate_uuid} = state
    aggregate_state = struct(aggregate_mod, uuid: aggregate_uuid)

    %{state | aggregate_state: aggregate_state}
  end

  defp execute_command(state, command, _context) do
    %{aggregate_mod: aggregate_mod, aggregate_state: aggregate_state} = state

    event =
      case aggregate_mod.execute(aggregate_state, command) do
        %{uuid: nil} = event -> %{event | uuid: UUID.generate()}
        event -> event
      end

    state =
      state
      |> store_event(event)
      |> apply_events([event])
      |> dispatch_event(event)

    {build_result(state, event), state}
  end

  defp build_result(state, event) do
    {event, state.aggregate_state}
  end

  defp store_event(state, event) do
    %{store_mod: store_mod, aggregate_uuid: aggregate_uuid} = state
    store_mod.put(aggregate_uuid, event)

    state
  end

  defp dispatch_event(state, event) do
    EventHandler.dispatch(event, state.aggregate_state)

    state
  end

  defp apply_events(state, events) when is_list(events) do
    %{aggregate_mod: aggregate_mod, aggregate_state: aggregate_state} = state

    aggregate_state =
      Enum.reduce(events, aggregate_state, fn event, state ->
        aggregate_mod.apply(state, event)
      end)

    %{state | aggregate_state: aggregate_state}
  end
end