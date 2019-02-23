defmodule Absence.Aggregate do
  defmacro __using__(_opts) do
    quote do
      use GenServer

      import Absence.Aggregate, only: [name: 2]

      def start_link(aggregate_id) do
        GenServer.start_link(__MODULE__, aggregate_id, name: name(__MODULE__, aggregate_id))
      end

      def init(aggregate_id) do
        {:ok, apply(__MODULE__, :__struct__, [[id: aggregate_id]])}
      end

      def handle_call({:execute, command}, from, aggregate) do
        event = __MODULE__.execute(aggregate, command)
        aggregate = __MODULE__.apply(aggregate, event)

        {:reply, event, aggregate}
      end
    end
  end

  def execute({_mod, _id} = aggregate, command) do
    {:ok, aggregate_pid} = find_aggregate(aggregate)

    GenServer.call(aggregate_pid, {:execute, command})
  end

  def execute(%aggregate_mod{id: aggregate_id}, command) do
    execute({aggregate_mod, aggregate_id}, command)
  end

  def name(aggregate_mod, aggregate_id) do
    {:via, Registry, {Absence.AggregateRegistry, {aggregate_mod, aggregate_id}}}
  end

  defp find_aggregate(aggregate) do
    case Registry.lookup(Absence.AggregateRegistry, aggregate) do
      [{pid, _}] -> {:ok, pid}
      [] -> Absence.AggregateSupervisor.start_aggregate(aggregate)
    end
  end
end
