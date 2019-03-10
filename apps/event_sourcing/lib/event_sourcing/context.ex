defmodule EventSourcing.Context do
  defstruct [
    :command,
    :command_uuid,
    :aggregate_uuid,
    :aggregate_mod
  ]
end
