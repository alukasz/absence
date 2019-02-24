defmodule EventSourcing.Aggregate do
  defmacro __using__(_opts) do
    quote do
      use GenServer

      import EventSourcing.Aggregate, only: [name: 2]

      def start_link(aggregate_uuid) do
        GenServer.start_link(__MODULE__, aggregate_uuid, name: name(__MODULE__, aggregate_uuid))
      end

      def init(aggregate_uuid) do
        {:ok, apply(__MODULE__, :__struct__, [[uuid: aggregate_uuid]])}
      end

      def handle_call({:execute, command}, from, aggregate) do
        event = __MODULE__.execute(aggregate, command)
        aggregate = __MODULE__.apply(aggregate, event)

        {:reply, event, aggregate}
      end
    end
  end

  def execute({_mod, _uuid} = aggregate, command) do
    {:ok, aggregate_pid} = find_aggregate(aggregate)

    GenServer.call(aggregate_pid, {:execute, command})
  end

  def execute(%aggregate_mod{id: aggregate_uuid}, command) do
    execute({aggregate_mod, aggregate_uuid}, command)
  end

  def name(aggregate_mod, aggregate_uuid) do
    {:via, Registry, {EventSourcing.AggregateRegistry, {aggregate_mod, aggregate_uuid}}}
  end

  defp find_aggregate(aggregate) do
    case Registry.lookup(EventSourcing.AggregateRegistry, aggregate) do
      [{pid, _}] -> {:ok, pid}
      [] -> EventSourcing.AggregateSupervisor.start_aggregate(aggregate)
    end
  end
end
