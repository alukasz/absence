defmodule EventSourcing.Dispatcher do
  alias EventSourcing.Context
  alias EventSourcing.Aggregate

  defmacro __using__(_opts) do
    quote do
      import EventSourcing.Dispatcher

      @before_compile EventSourcing.Dispatcher

      def dispatch({:ok, command}), do: dispatch(command)
      def dispatch({:error, _} = error), do: error
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def dispatch(command) do
        unregistered_command(command)
      end

      def dispatch(command, _) do
        unregistered_command(command)
      end

      defp unregistered_command(_command) do
        {:error, :unregistered_command}
      end
    end
  end

  defmacro dispatch(command_mod, opts) do
    aggregate_mod = Keyword.fetch!(opts, :to)
    identity = Keyword.fetch!(opts, :identity)

    quote do
      def dispatch(%unquote(command_mod){unquote(identity) => aggregate_uuid} = command) do
        context = %Context{
          command: command,
          aggregate_mod: unquote(aggregate_mod),
          aggregate_uuid: aggregate_uuid
        }

        Aggregate.execute_command({unquote(aggregate_mod), aggregate_uuid}, command, context)
      end
    end
  end
end
