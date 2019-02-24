defmodule EventSourcing.DispatcherTest do
  use ExUnit.Case

  alias Ecto.UUID

  defmodule Increment do
    defstruct [:uuid, :counter_uuid, :test_pid]
  end

  defmodule Incremented do
    defstruct [:uuid, :counter_uuid]
  end

  defmodule Counter do
    @behaviour EventSourcing.Aggregate
    defstruct [:uuid, value: 0]

    def execute(%Counter{} = counter, %Increment{test_pid: pid}) do
      send(pid, {:aggregate_called, __MODULE__})
      %Incremented{counter_uuid: counter.uuid}
    end

    def apply(%Counter{value: value} = counter, %Incremented{}) do
      %{counter | value: value + 1}
    end
  end

  defmodule Dispatcher do
    use EventSourcing.Dispatcher

    dispatch Increment, to: Counter, identity: :counter_uuid
  end

  describe "dispatch/2 macro" do
    test "defines dispatch/1 function" do
      assert {:dispatch, 1} in Dispatcher.__info__(:functions)
    end
  end

  describe "dispatch/1" do
    setup do
      command = %Increment{counter_uuid: UUID.generate(), test_pid: self()}

      {:ok, command: command}
    end

    test "dispatches command to aggregate", %{command: command} do
      Dispatcher.dispatch(command)

      assert_receive {:aggregate_called, Counter}
    end
  end
end
