defmodule EventSourcing.Dispatcher do
  defmacro __using__(_opts) do
    quote do
      import EventSourcing.Dispatcher

      @before_compile EventSourcing.Dispatcher
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def dispatch(_) do
        {:error, :unregistered_command}
      end
    end
  end

  defmacro dispatch(command_mod, opts) do
    aggregate_mod = Keyword.fetch!(opts, :to)
    identity = Keyword.fetch!(opts, :identity)

    quote do
      def dispatch(%unquote(command_mod){unquote(identity) => uuid} = command) do
        aggregate = {unquote(aggregate_mod), uuid}
        EventSourcing.Aggregates.execute_command(aggregate, command)
      end
    end
  end
end
