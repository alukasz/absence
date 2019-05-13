defmodule EventSourcing.UUID do
  @behaviour EventSourcing.UUIDGenerator
  @behaviour Ecto.Type

  @type t :: Ecto.UUID.t()

  defdelegate cast(term), to: Ecto.UUID
  defdelegate dump(term), to: Ecto.UUID
  defdelegate load(term), to: Ecto.UUID
  defdelegate type, to: Ecto.UUID

  @impl true
  def generate(), do: Ecto.UUID.generate()
end
