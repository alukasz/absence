defmodule EventSourcing.AggregateCase do
  use ExUnit.CaseTemplate

  alias EventSourcing.EventHandler

  using do
    quote do
      import EventSourcing.AggregateCase
    end
  end

  def aggregate_execute(%aggregate_mod{} = aggregate, command) do
    apply(aggregate_mod, :execute, [aggregate, command])
  end

  def aggregate_apply(%aggregate_mod{} = aggregate, event) do
    aggregate = apply(aggregate_mod, :apply, [aggregate, event])
    EventHandler.__fake_dispatch__(event, aggregate)

    aggregate
  end

  def event_handler_invoked(handler) when is_atom(handler) do
    assert_receive {:event_handler_called, ^handler}, 1000
  end
end
