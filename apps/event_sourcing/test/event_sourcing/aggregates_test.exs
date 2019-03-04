defmodule EventSourcing.AggregatesTest do
  use ExUnit.Case

  alias EventSourcing.Aggregates
  alias EventSourcing.Context
  alias EventSourcing.EventHandler
  alias Ecto.UUID
  alias EventSourcing.Counters.Aggregates.Counter
  alias EventSourcing.Counters.Commands.Increment
  alias EventSourcing.Counters.Events.Incremented
  alias EventSourcing.EventStore.EventStoreMock
  alias EventSourcing.EventHandlerMock

  @registry EventSourcing.AggregateRegistry

  describe "execute_command/2" do
    setup :aggregate
    setup :command
    setup :context

    test "returns event", %{aggregate: aggregate, command: command, context: context} do
      assert {%Incremented{}, _} = Aggregates.execute_command(aggregate, command, context)
    end

    test "returns updated aggregate", %{aggregate: aggregate, command: command, context: context} do
      assert {_, %Counter{value: 1}} = Aggregates.execute_command(aggregate, command, context)
    end

    test "starts process for aggregate", %{command: command, context: context} do
      aggregate = {Counter, UUID.generate()}
      refute is_pid(find_aggregate_pid(aggregate))

      Aggregates.execute_command(aggregate, command, context)

      assert is_pid(find_aggregate_pid(aggregate))
    end

    test "reuses aggregate process", %{aggregate: aggregate, command: command, context: context} do
      Aggregates.execute_command(aggregate, command, context)
      pid1 = find_aggregate_pid(aggregate)
      Aggregates.execute_command(aggregate, command, context)
      pid2 = find_aggregate_pid(aggregate)

      assert pid1 == pid2
    end

    test "creates process per aggregate", %{command: command, context: context} = test_context do
      {:ok, aggregate: aggregate1} = aggregate(test_context)
      {:ok, aggregate: aggregate2} = aggregate(test_context)

      Aggregates.execute_command(aggregate1, command, context)
      pid1 = find_aggregate_pid(aggregate1)
      Aggregates.execute_command(aggregate2, command, context)
      pid2 = find_aggregate_pid(aggregate2)

      refute aggregate1 == aggregate2
      refute pid1 == pid2
    end

    test "stores event in store under aggregate uuid", %{
      aggregate: {_mod, uuid} = aggregate,
      command: command,
      context: context
    } do
      {event, _} = Aggregates.execute_command(aggregate, command, context)

      assert_receive {:store_put, ^uuid, ^event}
    end

    test "dispatches events to event handlers", %{aggregate: aggregate, command: command, context: context} do
      EventHandler.register_handler(Incremented, EventHandlerMock)

      {event, aggregate} = Aggregates.execute_command(aggregate, command, context)

      assert_receive {:event_handler_called, ^event, ^aggregate}
    end
  end

  defp aggregate(_) do
    aggregate = {Counter, UUID.generate()}
    {:ok, _} = start_supervised({Aggregates.Aggregate, {aggregate, [store: EventStoreMock]}}, id: aggregate)

    {:ok, aggregate: aggregate}
  end

  defp command(_) do
    command = %Increment{test_pid: self()}

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
