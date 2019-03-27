defmodule EventSourcing.UUID do
  @behaviour EventSourcing.UUIDGenerator

  alias Ecto.UUID

  @impl UUIDGenerator
  def generate(), do: UUID.generate()
end
