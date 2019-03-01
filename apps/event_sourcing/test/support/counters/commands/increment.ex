defmodule EventSourcing.Counters.Commands.Increment do
  defstruct [:uuid, :counter_uuid, :test_pid]
end
