defmodule EventSourcing.AggregatesTest do
  use ExUnit.Case

  alias EventSourcing.Aggregates
  alias Ecto.UUID
  alias EventSourcing.Support.Counters.Aggregates.Counter
  alias EventSourcing.Support.Counters.Commands.Increment
  alias EventSourcing.Support.Counters.Events.Incremented
  alias EventSourcing.Support.EventStore.InMemoryEventStore

  @registry EventSourcing.AggregateRegistry

  describe "execute_command/2" do
    setup :aggregate
    setup :command

    test "returns event", %{aggregate: aggregate, command: command} do
      assert {%Incremented{}, _} = Aggregates.execute_command(aggregate, command)
    end

    test "returns updated aggregate", %{aggregate: aggregate, command: command} do
      assert {_, %Counter{value: 1}} = Aggregates.execute_command(aggregate, command)
    end

    test "starts process for aggregate", %{aggregate: aggregate, command: command} do
      refute is_pid(find_aggregate_pid(aggregate))

      Aggregates.execute_command(aggregate, command)

      assert is_pid(find_aggregate_pid(aggregate))
    end

    test "reuses aggregate process", %{aggregate: aggregate, command: command} do
      Aggregates.execute_command(aggregate, command)
      pid1 = find_aggregate_pid(aggregate)
      Aggregates.execute_command(aggregate, command)
      pid2 = find_aggregate_pid(aggregate)

      assert pid1 == pid2
    end

    test "creates process per aggregate", %{command: command} = context do
      {:ok, aggregate: aggregate1} = aggregate(context)
      {:ok, aggregate: aggregate2} = aggregate(context)

      Aggregates.execute_command(aggregate1, command)
      pid1 = find_aggregate_pid(aggregate1)
      Aggregates.execute_command(aggregate2, command)
      pid2 = find_aggregate_pid(aggregate2)

      refute aggregate1 == aggregate2
      refute pid1 == pid2
    end

    test "stores event in store under aggregate uuid", %{
      aggregate: {_mod, uuid} = aggregate,
      command: command
    } do
      {event, _} = Aggregates.execute_command(aggregate, command, store: InMemoryEventStore)

      assert_receive {:store_put, ^uuid, ^event}
    end
  end

  defp aggregate(_) do
    aggregate = {Counter, UUID.generate()}

    {:ok, aggregate: aggregate}
  end

  defp command(_) do
    command = %Increment{test_pid: self()}

    {:ok, command: command}
  end

  defp find_aggregate_pid(aggregate) do
    case Registry.lookup(@registry, aggregate) do
      [{pid, _}] -> pid
      _ -> nil
    end
  end
end
