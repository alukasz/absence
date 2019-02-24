defmodule EventSourcing.AggregatesTest do
  use ExUnit.Case

  alias EventSourcing.Aggregates
  alias Ecto.UUID

  @registry EventSourcing.AggregateRegistry

  defmodule Increment do
    defstruct [:uuid, :counter_uuid]
  end

  defmodule Incremented do
    defstruct [:uuid, :counter_uuid]
  end

  defmodule Counter do
    @behaviour EventSourcing.Aggregate
    defstruct [:uuid, value: 0]

    def execute(%Counter{} = counter, %Increment{}) do
      %Incremented{counter_uuid: counter.uuid}
    end

    def apply(%Counter{value: value} = counter, %Incremented{}) do
      %{counter | value: value + 1}
    end
  end

  describe "execute_command/2" do
    setup :aggregate

    test "returns event", %{aggregate: aggregate} do
      assert {%Incremented{}, _} = Aggregates.execute_command(aggregate, %Increment{})
    end

    test "returns updated aggregate", %{aggregate: aggregate} do
      assert {_, %Counter{value: 1}} = Aggregates.execute_command(aggregate, %Increment{})
    end

    test "starts process for aggregate", %{aggregate: aggregate} do
      refute is_pid(find_aggregate_pid(aggregate))

      Aggregates.execute_command(aggregate, %Increment{})

      assert is_pid(find_aggregate_pid(aggregate))
      assert aggregate |> find_aggregate_pid() |> is_pid()
    end

    test "reuses aggregate process", %{aggregate: aggregate} do
      Aggregates.execute_command(aggregate, %Increment{})
      pid1 = find_aggregate_pid(aggregate)
      Aggregates.execute_command(aggregate, %Increment{})
      pid2 = find_aggregate_pid(aggregate)

      assert pid1 == pid2
    end

    test "creates process per aggregate", context do
      {:ok, aggregate: aggregate1} = aggregate(context)
      {:ok, aggregate: aggregate2} = aggregate(context)

      Aggregates.execute_command(aggregate1, %Increment{})
      pid1 = find_aggregate_pid(aggregate1)
      Aggregates.execute_command(aggregate2, %Increment{})
      pid2 = find_aggregate_pid(aggregate2)

      refute aggregate1 == aggregate2
      refute pid1 == pid2
    end
  end

  defp aggregate(_) do
    aggregate = {Counter, UUID.generate()}

    {:ok, aggregate: aggregate}
  end

  defp find_aggregate_pid(aggregate) do
    case Registry.lookup(@registry, aggregate) do
      [{pid, _}] -> pid
      _ -> nil
    end
  end
end
