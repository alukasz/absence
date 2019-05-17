defmodule EventSourcing.Dispatcher do
  alias EventSourcing.Context
  alias EventSourcing.Aggregate

  @default_dispatcher Application.get_env(:event_sourcing, :dispatcher)

  defmacro __using__(opts) do
    dispatcher_mod = Keyword.get(opts, :dispatcher, @default_dispatcher)

    quote do
      import unquote(dispatcher_mod), only: [dispatch: 2]
      @before_compile EventSourcing.Dispatcher

      def dispatch({:ok, command}), do: dispatch(command)
      def dispatch({:error, _} = error), do: error
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def dispatch(command) do
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
