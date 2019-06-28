defmodule EventSourcing.FakeDispatcher do
  use Agent

  def start_link(opts) do
    Agent.start_link(fn -> [] end, name: name(Keyword.get(opts, :name, self())))
  end

  def name(name \\ self()) do
    {:via, Registry, {EventSourcing.FakeDispatcherRegistry, name}}
  end

  def commands_dispatched do
    Agent.get(name(), fn dispatched ->
      Enum.map(dispatched, &elem(&1, 2))
    end)
  end

  def dispatched do
    Agent.get(name(), & &1)
  end

  defmacro dispatch(command_mod, opts) do
    aggregate_mod = Keyword.fetch!(opts, :to)
    identity = Keyword.fetch!(opts, :identity)

    quote do
      def dispatch(%unquote(command_mod){unquote(identity) => aggregate_uuid} = command) do
        Agent.update(EventSourcing.FakeDispatcher.name(), fn dispatched ->
          [{unquote(aggregate_mod), aggregate_uuid, command} | dispatched]
        end)
      end

      def dispatch(%unquote(command_mod){} = command, opts) do
        aggregate_mod = Keyword.get(opts, :to, unquote(aggregate_mod))
        identity = Keyword.get(opts, :identity, unquote(identity))
        aggregate_uuid = Map.fetch!(command, identity)

        Agent.update(EventSourcing.FakeDispatcher.name(), fn dispatched ->
          [{aggregate_mod, aggregate_uuid, command} | dispatched]
        end)
      end
    end
  end
end
