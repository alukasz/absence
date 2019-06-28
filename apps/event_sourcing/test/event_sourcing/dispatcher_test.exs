defmodule EventSourcing.DispatcherTest do
  use ExUnit.Case

  alias EventSourcing.UUID
  alias EventSourcing.Counters.Aggregates.Counter
  alias EventSourcing.Counters.Aggregates.Counter2
  alias EventSourcing.Counters.Commands.Increment
  alias EventSourcing.Counters.Commands.Decrement
  alias EventSourcing.DispatcherMock

  describe "dispatch/2 macro" do
    test "defines dispatch/1 function" do
      assert {:dispatch, 1} in DispatcherMock.__info__(:functions)
    end

    test "defines dispatch/2 function" do
      assert {:dispatch, 2} in DispatcherMock.__info__(:functions)
    end
  end

  setup do
    command = %Increment{
      uuid: UUID.generate(),
      counter_uuid: UUID.generate(),
      test_pid: self()
    }

    {:ok, command: command}
  end

  describe "dispatch/1" do
    test "dispatches command to aggregate", %{command: command} do
      DispatcherMock.dispatch(command)

      assert_receive {:aggregate_called, Counter}
    end

    test "allows to pass {:ok, command} tuple", %{command: command} do
      DispatcherMock.dispatch({:ok, command})

      assert_receive {:aggregate_called, Counter}
    end

    test "passing {:error, _} tuple returns it" do
      error_tuple = {:error, nil}

      assert DispatcherMock.dispatch(error_tuple) == error_tuple
    end

    test "returns error tuple if command is not registered" do
      command = %Decrement{counter_uuid: UUID.generate(), test_pid: self()}

      {:error, :unregistered_command} = DispatcherMock.dispatch(command)

      refute_receive {:aggregate_called, Counter}
    end
  end

  describe "dispatch/2" do
    test "dispatches command to aggregate", %{command: command} do
      uuid = command.counter_uuid
      DispatcherMock.dispatch(command, to: Counter, identity: :counter_uuid)

      assert_receive {:aggregate_called, Counter, ^uuid}
    end

    test "allows to override aggregate module", %{command: command} do
      uuid = command.counter_uuid
      DispatcherMock.dispatch(command, to: Counter2, identity: :counter_uuid)

      assert_receive {:aggregate_called, Counter2, ^uuid}
    end

    test "allows to override aggregate identity", %{command: command} do
      uuid = command.uuid
      DispatcherMock.dispatch(command, to: Counter, identity: :uuid)

      assert_receive {:aggregate_called, Counter, ^uuid}
    end

    test "allows to override aggregate module and identity", %{command: command} do
      uuid = command.uuid
      DispatcherMock.dispatch(command, to: Counter2, identity: :uuid)

      assert_receive {:aggregate_called, Counter2, ^uuid}
    end

    test "returns error tuple if command is not registered" do
      command = %Decrement{counter_uuid: UUID.generate(), test_pid: self()}

      {:error, :unregistered_command} = DispatcherMock.dispatch(command, to: Counter2)

      refute_receive {:aggregate_called, Counter2}
    end
  end
end
