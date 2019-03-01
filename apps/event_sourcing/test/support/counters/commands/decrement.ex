defmodule EventSourcing.Counters.Commands.Decrement do
  defstruct [:uuid, :counter_uuid, :test_pid]
end
