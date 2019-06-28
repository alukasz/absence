defmodule EventSourcing.EventHandlerTest do
  use ExUnit.Case

  alias EventSourcing.EventHandler
  alias EventSourcing.Counters.Aggregates.Counter
  alias EventSourcing.Counters.Events.Incremented

  describe "handle/2,3 macro" do
    defmodule HandleTest do
      use EventSourcing.EventHandler

      handle %Incremented{}, %Counter{}, do: :ok

      handle %Incremented{}, do: :ok
    end

    EventHandler.register_handler(HandleTest)

    test "defines handle_event/2 function" do
      assert {:handle_event, 2} in HandleTest.__info__(:functions)
    end

    test "register event handlers" do
      assert registered_handler?(Incremented, HandleTest)
    end

    test "adds event to __events__" do
      assert Incremented in HandleTest.__events__()
    end
  end

  setup do
    aggregate = %Counter{}
    event = %Incremented{test_pid: self()}
    handler = EventSourcing.EventHandlerMock
    EventSourcing.EventHandler.register_handler(handler)

    {:ok, aggregate: aggregate, event: event, handler: handler}
  end

  describe "register_handler/1" do
    defmodule RegisterHandlerTest do
      use EventSourcing.EventHandler

      handle %Incremented{}, do: :ok
    end

    test "adds module as event handler", %{event: %event_mod{}} do
      EventHandler.register_handler(RegisterHandlerTest)

      assert registered_handler?(event_mod, RegisterHandlerTest)
    end
  end

  describe "dispatch/2" do
    test "sends event to all handlers", %{event: event, aggregate: aggregate} do
      EventHandler.dispatch(event, aggregate)

      assert_receive {:event_handler_called, ^event, ^aggregate}
    end
  end

  describe "matching_handlers/1" do
    test "returns list of event handlers that responds to event", %{
      event: event,
      handler: handler
    } do
      assert handler in EventHandler.matching_handlers(event)
    end

    defmodule UnregisteredEvent do
      defstruct [:id]
    end

    test "returns empty list if no handler is registered for event" do
      assert EventHandler.matching_handlers(%UnregisteredEvent{}) == []
    end
  end

  defp registered_handler?(event, handler) do
    %{handlers: handlers} = :sys.get_state(EventHandler)

    handler in Map.get(handlers, event, [])
  end
end
