defmodule EventSourcing.Support.Counters.Events.Incremented do
  defstruct [:uuid, :counter_uuid, :test_pid]
end
