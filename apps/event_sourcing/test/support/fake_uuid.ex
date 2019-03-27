defmodule EventSourcing.FakeUUID do
  @behaviour EventSourcing.UUIDGenerator

  @impl true
  def generate(), do: nil
end
