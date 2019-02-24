defmodule EventSourcing.Aggregates.Aggregate do
  use GenServer

  import EventSourcing.Aggregate

  @registry EventSourcing.AggregateRegistry

  def start_link({_mod, _uuid} = aggregate) do
    GenServer.start_link(__MODULE__, aggregate, name: name(aggregate))
  end

  def command(pid, command) do
    GenServer.call(pid, command)
  end

  def name({_mod, _uuid} = aggregate) do
    {:via, Registry, {@registry, aggregate}}
  end

  def init({aggregate_mod, aggregate_uuid}) do
    {:ok, apply(aggregate_mod, :__struct__, [[uuid: aggregate_uuid]])}
  end

  def handle_call({:command, command}, _from, aggregate) do
    event = __MODULE__.execute(aggregate, command)
    aggregate = __MODULE__.apply(aggregate, event)

    {:reply, event, aggregate}
  end
end
