defmodule EventSourcing.EventHandler do
  use GenServer

  defmacro __using__(_opts) do
    quote do
      import EventSourcing.EventHandler, only: [handle: 2, handle: 3]

      @before_compile EventSourcing.EventHandler

      Module.register_attribute(__MODULE__, :events, accumulate: true)
    end
  end

  defmacro __before_compile__(env) do
    events = Module.get_attribute(env.module, :events) |> Enum.uniq()

    quote do
      def __events__, do: unquote(events)
    end
  end

  defmacro handle(event, aggregate \\ quote(do: _), do: block) do
    event_mod = get_event_mod(event)

    quote do
      @events unquote(event_mod)

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

  def register_handler(handler) do
    Code.ensure_compiled(handler)

    unless function_exported?(handler, :__events__, 0) do
      raise ArgumentError,
            "Module #{handler} does not export __events__/0 function\n" <>
              "Did you forget to `use EventSourcing.EventHandler`?"
    end

    GenServer.call(__MODULE__, {:register_handler, handler})
  end

  def dispatch(event, aggregate) do
    GenServer.cast(__MODULE__, {:dispatch, event, aggregate})
  end

  def __fake_dispatch__(event, aggregate) do
    GenServer.call(__MODULE__, {:fake_dispatch, event, aggregate})
  end

  def matching_handlers(event) do
    GenServer.call(__MODULE__, {:matching_handlers, event})
  end

  def init(_opts) do
    state = %{
      handlers: %{}
    }

    {:ok, state}
  end

  def handle_call({:register_handler, handler}, _from, state) do
    state =
      Enum.reduce(handler.__events__(), state, fn event, state ->
        update_in(state.handlers[event], fn
          nil -> [handler]
          handlers -> Enum.uniq([handler | handlers])
        end)
      end)

    {:reply, :ok, state}
  end

  def handle_call({:fake_dispatch, %mod{} = _, _}, {pid, _}, %{handlers: handlers} = state) do
    handlers
    |> Map.get(mod, [])
    |> Enum.each(&send(pid, {:event_handler_called, &1}))

    {:reply, :ok, state}
  end

  def handle_call({:matching_handlers, %mod{} = _event}, _from, %{handlers: handlers} = state) do
    {:reply, Map.get(handlers, mod, []), state}
  end

  def handle_cast({:dispatch, %mod{} = event, aggregate}, %{handlers: handlers} = state) do
    handlers
    |> Map.get(mod, [])
    |> Enum.each(&spawn(&1, :handle_event, [event, aggregate]))

    {:noreply, state}
  end
end
