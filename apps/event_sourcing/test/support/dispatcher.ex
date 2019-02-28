defmodule EventSourcing.Support.Dispatcher do
  use EventSourcing.Dispatcher

  alias EventSourcing.Support.Counters.Aggregates.Counter
  alias EventSourcing.Support.Counters.Commands.Increment

  dispatch Increment, to: Counter, identity: :counter_uuid
end