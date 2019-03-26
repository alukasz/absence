defmodule EventSourcing.EventStore.AgentEventStore do
  @behaviour EventSourcing.EventStore

  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> {1, %{}} end, name: __MODULE__)
  end

  def put(store \\ __MODULE__, uuid, event) do
    Agent.update(store, fn {count, store} ->
      {count + 1, Map.update(store, uuid, [event], fn events -> [event | events] end)}
    end)
  end

  def get(store \\ __MODULE__, uuid) do
    Agent.get(store, fn {_, store} -> Map.get(store, uuid, []) end)
    |> Enum.reverse()
  end

  def next_event_number(store \\ __MODULE__) do
    Agent.get_and_update(store, fn {count, store}-> {count, {count + 1, store}} end)
  end
end
