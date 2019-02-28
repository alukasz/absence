defmodule EventSourcing.DispatcherTest do
  use ExUnit.Case

  alias Ecto.UUID
  alias EventSourcing.Support.Counters.Aggregates.Counter
  alias EventSourcing.Support.Counters.Commands.Increment
  alias EventSourcing.Support.Counters.Commands.Decrement
  alias EventSourcing.Support.Dispatcher

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

    test "returns error tuple if command is not registered" do
      command = %Decrement{counter_uuid: UUID.generate(), test_pid: self()}

      {:error, :unregistered_command} = Dispatcher.dispatch(command)

      refute_receive {:aggregate_called, Counter}
    end
  end
end
