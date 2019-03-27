defmodule EventSourcing.UUIDGenerator do
  @callback generate() :: Ecto.UUID.t() | nil
end
