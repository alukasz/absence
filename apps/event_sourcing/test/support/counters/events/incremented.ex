defmodule EventSourcing.Counters.Events.Incremented do
  @derive Jason.Encoder
  defstruct [:uuid, :counter_uuid, :test_pid]
end
