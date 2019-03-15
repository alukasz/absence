defmodule EventSourcing.Counters.Commands.Decrement do
  @derive Jason.Encoder
  defstruct [:uuid, :counter_uuid, :test_pid]
end
