defmodule EventSourcing.UUID do
  @behaviour EventSourcing.UUIDGenerator

  @type t :: Ecto.UUID.t()

  @impl true
  def generate(), do: Ecto.UUID.generate()
end
