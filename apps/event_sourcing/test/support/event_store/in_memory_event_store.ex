defmodule EventSourcing.Support.EventStore.InMemoryEventStore do
  @behaviour EventSourcing.EventStore

  def put(uuid, %{test_pid: pid} = event) when is_pid(pid) do
    send(pid, {:store_put, uuid, event})
    :ok
  end

  def get(_uuid), do: []
end
