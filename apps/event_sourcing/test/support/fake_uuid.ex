defmodule EventSourcing.FakeUUID do
  @behaviour EventSourcing.UUIDGenerator

  @impl UUIDGenerator
  def generate(), do: nil
end
