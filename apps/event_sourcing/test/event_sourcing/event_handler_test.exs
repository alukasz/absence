defmodule EventSourcing.EventHandlerTest do
  use ExUnit.Case

  alias EventSourcing.EventHandler

  defmodule Incremented do
    defstruct [:uuid, :counter_uuid, :test_pid]
  end

  defmodule Counter do
    defstruct [:uuid, value: 0]
  end

  defmodule TestHandler do
    def handle_event(%{test_pid: pid} = event, aggregate) do
      send(pid, {:event_handler_called, event, aggregate})
    end
  end

  describe "handle/2,3 macro" do
    defmodule HandleTest do
      use EventSourcing.EventHandler

      handle %Incremented{}, do: :ok

      handle %Incremented{}, %Counter{}, do: :ok
    end

    test "defines handle_event/2 function" do
      assert {:handle_event, 2} in HandleTest.__info__(:functions)
    end

    test "register event handlers" do
      assert registered_handler?(Incremented, HandleTest)
    end
  end

  setup do
    aggregate = %Counter{}
    event = %Incremented{test_pid: self()}
    handler = TestHandler

    {:ok, aggregate: aggregate, event: event, handler: handler}
  end

  describe "register_handler/2" do
    test "adds module as event handler", %{event: %event{}} do
      EventHandler.register_handler(event, TestHandler)

      assert registered_handler?(event, TestHandler)
    end
  end

  describe "dispatch/2" do
    setup %{event: %event{}} do
      EventHandler.register_handler(event, TestHandler)
    end

    test "sends event to all handlers", %{event: event, aggregate: aggregate} do
      EventHandler.dispatch(event, aggregate)

      assert_receive {:event_handler_called, ^event, ^aggregate}
    end
  end

  defp registered_handler?(event, handler) do
    %{handlers: handlers} = :sys.get_state(EventHandler)

    handler in Map.get(handlers, event, [])
  end
end
