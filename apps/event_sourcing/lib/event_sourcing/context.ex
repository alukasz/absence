defmodule EventSourcing.Context do
  defstruct [
    :command_uuid,
    :command,
    :aggregate_uuid,
    :aggregate_mod,
    :identity
  ]
end
