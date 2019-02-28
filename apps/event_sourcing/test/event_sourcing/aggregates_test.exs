defmodule EventSourcing.AggregatesTest do
  use ExUnit.Case

  alias EventSourcing.Aggregates
  alias Ecto.UUID

  @registry EventSourcing.AggregateRegistry

  defmodule Increment do
    defstruct [:uuid, :counter_uuid, :test_pid]
  end

  defmodule Incremented do
    defstruct [:uuid, :counter_uuid, :test_pid]
  end

  defmodule Counter do
    @behaviour EventSourcing.Aggregate
    defstruct [:uuid, value: 0]

    def execute(%Counter{} = counter, %Increment{test_pid: pid}) do
      %Incremented{counter_uuid: counter.uuid, test_pid: pid}
    end

    def apply(%Counter{value: value} = counter, %Incremented{}) do
      %{counter | value: value + 1}
    end
  end

  defmodule EventStore do
    @behaviour EventSourcing.EventStore

    def put(uuid, %{test_pid: pid} = event) when is_pid(pid) do
      send(pid, {:store_put, uuid, event})
    end

    def get(_uuid), do: []
  end

  defmodule EventHandler do
    use EventSourcing.EventHandler

    handle %Incremented{test_pid: pid} = event, aggregate do
      send(pid, {:event_handler, event, aggregate})
    end
  end

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
      {event, _} = Aggregates.execute_command(aggregate, command, store: EventStore)

      assert_receive {:store_put, ^uuid, ^event}
    end

    test "dispatches events to event handlers", %{aggregate: aggregate, command: command} do
      {event, aggregate} = Aggregates.execute_command(aggregate, command)

      assert_receive {:event_handler, ^event, ^aggregate}
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
