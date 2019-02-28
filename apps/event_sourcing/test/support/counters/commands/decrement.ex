defmodule EventSourcing.Support.Counters.Commands.Decrement do
  defstruct [:uuid, :counter_uuid, :test_pid]
end
