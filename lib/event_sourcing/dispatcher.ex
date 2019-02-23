defmodule EventSourcing.Dispatcher do
  defmacro __using__(_opts) do
    quote do
      import EventSourcing.Dispatcher
    end
  end

  defmacro dispatch(command_mod, opts) do
    aggregate_mod = Keyword.fetch!(opts, :to)
    identity = Keyword.fetch!(opts, :identity)

    quote do
      def dispatch(%unquote(command_mod){unquote(identity) => id} = command) do
        aggregate = {unquote(aggregate_mod), id}
        EventSourcing.Aggregate.execute(aggregate, command)
      end
    end
  end
end
