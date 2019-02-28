defmodule EventSourcing.EventHandler do
  use GenServer

  alias __MODULE__

  defmacro __using__(_opts) do
    {:ok, _} = Application.ensure_all_started(:event_sourcing)

    quote do
      import EventSourcing.EventHandler, only: [handle: 2, handle: 3]
    end
  end

  defmacro handle(event, aggregate \\ quote(do: _), do: block) do
    event_mod = get_event_mod(event)

    quote location: :keep do
      EventHandler.register_handler(unquote(event_mod), __MODULE__)

      def handle_event(unquote(event), unquote(aggregate)) do
        unquote(block)
      end
    end
  end

  defp get_event_mod({:=, _, [ast, _]}), do: get_event_mod(ast)
  defp get_event_mod({:%, _, [{:__aliases__, _, _} = mod, _]}), do: mod

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def register_handler(event, handler) do
    GenServer.call(__MODULE__, {:register_handler, event, handler})
  end

  def dispatch(event, aggregate) do
    GenServer.cast(__MODULE__, {:dispatch, event, aggregate})
  end

  def init(_opts) do
    state = %{
      handlers: %{}
    }

    {:ok, state}
  end

  def handle_call({:register_handler, event, handler}, _from, state) do
    state =
      update_in(state.handlers[event], fn
        nil -> [handler]
        handlers -> [handler | handlers]
      end)

    {:reply, :ok, state}
  end

  def handle_cast({:dispatch, %mod{} = event, aggregate}, %{handlers: handlers} = state) do
    handlers
    |> Map.get(mod, [])
    |> Enum.each(&spawn(&1, :handle_event, [event, aggregate]))

    {:noreply, state}
  end
end
