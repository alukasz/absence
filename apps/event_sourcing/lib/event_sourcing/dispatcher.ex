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
      def dispatch(_command) do
        {:error, :unregistered_command}
      end

      def dispatch(_command, _opts) do
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

        case Aggregate.execute_command({unquote(aggregate_mod), aggregate_uuid}, command, context) do
          {:ok, _, _} -> :ok
          error -> error
        end
      end

      def dispatch(%unquote(command_mod){} = command, opts) do
        aggregate_mod = Keyword.get(opts, :to, unquote(aggregate_mod))
        identity = Keyword.get(opts, :identity, unquote(identity))
        aggregate_uuid = Map.fetch!(command, identity)

        context = %Context{
          command: command,
          aggregate_mod: aggregate_mod,
          aggregate_uuid: aggregate_uuid
        }

        case Aggregate.execute_command({aggregate_mod, aggregate_uuid}, command, context) do
          {:ok, _, _} -> :ok
          error -> error
        end
      end
    end
  end
end
