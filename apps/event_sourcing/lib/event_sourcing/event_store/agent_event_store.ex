defmodule EventSourcing.EventStore.AgentEventStore do
  @behaviour EventSourcing.EventStore

  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def put(uuid, event) do
    Agent.update(__MODULE__, fn store ->
      Map.update(store, uuid, [event], fn events -> [event | events] end)
    end)
  end

  def get(uuid) do
    __MODULE__
    |> Agent.get(fn store -> Map.get(store, uuid, []) end)
    |> Enum.reverse()
  end
end
