defmodule EventSourcing.Counters.Aggregates.Counter do
  @behaviour EventSourcing.Aggregate

  alias EventSourcing.Counters.Commands.Increment
  alias EventSourcing.Counters.Events.Incremented

  defstruct [:uuid, value: 0]

  def execute(%__MODULE__{} = counter, %Increment{test_pid: pid}) do
    send(pid, {:aggregate_called, __MODULE__})
    %Incremented{counter_uuid: counter.uuid, test_pid: pid}
  end

  def apply(%__MODULE__{value: value} = counter, %Incremented{}) do
    %{counter | value: value + 1}
  end
end
