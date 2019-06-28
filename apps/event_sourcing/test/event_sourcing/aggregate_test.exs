defmodule EventSourcing.AggregateTest do
  use ExUnit.Case

  alias EventSourcing.Aggregate
  alias EventSourcing.Context
  alias EventSourcing.EventHandler
  alias EventSourcing.Counters.Aggregates.Counter
  alias EventSourcing.Counters.Commands.Increment
  alias EventSourcing.Counters.Events.Incremented
  alias EventSourcing.EventStore.EventStoreMock
  alias EventSourcing.EventHandlerMock
  alias EventSourcing.UUID
  alias EventSourcing.AggregateHelper

  @registry EventSourcing.AggregateRegistry

  describe "execute_command/2" do
    setup :aggregate
    setup :command
    setup :context

    test "invokes aggregate with command", %{
      aggregate: aggregate,
      command: command,
      context: context
    } do
      Aggregate.execute_command(aggregate, command, context)

      assert_receive {:aggregate_called, Counter, _}
    end

    test "adds UUID to command if not exist", %{
      aggregate: aggregate,
      command: command,
      context: context
    } do
      command = %{command | uuid: nil}

      Aggregate.execute_command(aggregate, command, context)

      assert_receive {:aggregate_called, Counter, _, command}
      refute command.uuid == nil
    end

    test "returns event", %{aggregate: aggregate, command: command, context: context} do
      assert {:ok, %Incremented{}, _} = Aggregate.execute_command(aggregate, command, context)
    end

    test "generates UUID for event", %{aggregate: aggregate, command: command, context: context} do
      start_aggregate(aggregate)

      assert {:ok, event, _} = Aggregate.execute_command(aggregate, command, context)

      refute event.uuid == nil
    end

    test "returns updated aggregate", %{aggregate: aggregate, command: command, context: context} do
      assert {:ok, _, %Counter{value: 1}} = Aggregate.execute_command(aggregate, command, context)
    end

    test "starts process for aggregate", %{command: command, context: context} do
      aggregate = {Counter, UUID.generate()}
      refute is_pid(find_aggregate_pid(aggregate))

      Aggregate.execute_command(aggregate, command, context)

      assert is_pid(find_aggregate_pid(aggregate))
    end

    test "reuses aggregate process", %{aggregate: aggregate, command: command, context: context} do
      Aggregate.execute_command(aggregate, command, context)
      pid1 = find_aggregate_pid(aggregate)
      Aggregate.execute_command(aggregate, command, context)
      pid2 = find_aggregate_pid(aggregate)

      assert pid1 == pid2
    end

    test "creates process per aggregate", %{command: command, context: context} do
      aggregate1 = aggregate()
      aggregate2 = aggregate()

      Aggregate.execute_command(aggregate1, command, context)
      pid1 = find_aggregate_pid(aggregate1)
      Aggregate.execute_command(aggregate2, command, context)
      pid2 = find_aggregate_pid(aggregate2)

      refute aggregate1 == aggregate2
      refute pid1 == pid2
    end

    test "stores event in store under aggregate uuid", %{
      aggregate: {_mod, uuid} = aggregate,
      command: command,
      context: context
    } do
      start_aggregate(aggregate)

      {:ok, event, _} = Aggregate.execute_command(aggregate, command, context)

      assert_receive {:store_put, ^uuid, ^event}
    end

    test "dispatches events to event handlers", %{
      aggregate: aggregate,
      command: command,
      context: context
    } do
      EventHandler.register_handler(EventHandlerMock)

      {:ok, event, _aggregate} = Aggregate.execute_command(aggregate, command, context)

      assert_receive {:event_handler_called, ^event, %Counter{}}
    end
  end

  describe "get/1" do
    setup :aggregate

    test "returns aggregate state with", %{aggregate: aggregate} do
      assert %Counter{value: 0} = Aggregate.get(aggregate)
    end
  end

  defp aggregate(_) do
    {:ok, aggregate: aggregate()}
  end

  defp aggregate, do: {Counter, UUID.generate()}

  defp start_aggregate(%{aggregate: aggregate} = _text_context) do
    start_aggregate(aggregate)
  end

  defp start_aggregate({mod, uuid}) do
    aggregate = struct(mod, uuid: uuid)
    pid = AggregateHelper.start_aggregate(aggregate, event_store: EventStoreMock)

    {aggregate, pid}
  end

  defp command(_) do
    command = %Increment{uuid: UUID.generate(), test_pid: self()}

    {:ok, command: command}
  end

  defp context(_) do
    context = %Context{}

    {:ok, context: context}
  end

  defp find_aggregate_pid(aggregate) do
    case Registry.lookup(@registry, aggregate) do
      [{pid, _}] -> pid
      _ -> nil
    end
  end
end
