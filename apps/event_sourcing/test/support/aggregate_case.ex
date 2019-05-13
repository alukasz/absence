defmodule EventSourcing.AggregateCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import EventSourcing.DataCase, only: [errors_on: 1]
    end
  end

  setup do
    EventSourcing.EventStore.AgentEventStore.__reset__()

    :ok
  end
end
