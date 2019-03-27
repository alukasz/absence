defmodule EventSourcing.UUIDGenerator do
  @callback generate() :: EventSourcing.UUID.t() | nil
end
