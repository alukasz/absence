defmodule EventSourcing.EventHandlerMock do
  def handle_event(%{test_pid: pid} = event, aggregate) do
    send(pid, {:event_handler_called, event, aggregate})
  end

  def __events__ do
    [
      EventSourcing.Counters.Events.Incremented
    ]
  end
end
