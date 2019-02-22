defmodule Absence.Aggregate do
  defmacro __using__(_opts) do
    quote do
      @before_compile Absence.Aggregate
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      use GenServer

      import Absence.Aggregate, only: [name: 2]

      def start_link(aggregate_id) do
        GenServer.start_link(__MODULE__, aggregate_id, name: name(__MODULE__, aggregate_id))
      end

      def init(aggregate_id) do
        {:ok, %__MODULE__{id: aggregate_id}}
      end

      def handle_call({:apply, command}, from, state) do
        {:ok, events, state} = __MODULE__.apply(command, state)

        IO.inspect events, label: "events"

        {:reply, :ok, state}
      end
    end
  end

  def execute({_mod, _id} = aggregate, command) do
    {:ok, aggregate_pid} = find_aggregate(aggregate)

    GenServer.call(aggregate_pid, {:apply, command})
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
