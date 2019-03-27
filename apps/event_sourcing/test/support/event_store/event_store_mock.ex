defmodule EventSourcing.EventStore.EventStoreMock do
  @behaviour EventSourcing.EventStore

  def start_link(_), do: {:ok, self()}

  def put(uuid, %{test_pid: pid} = event) when is_pid(pid) do
    send(pid, {:store_put, uuid, event})
    :ok
  end

  def get(_uuid), do: []
end
