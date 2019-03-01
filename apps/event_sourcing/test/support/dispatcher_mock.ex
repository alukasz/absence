defmodule EventSourcing.DispatcherMock do
  use EventSourcing.Dispatcher

  alias EventSourcing.Counters.Aggregates.Counter
  alias EventSourcing.Counters.Commands.Increment

  dispatch Increment, to: Counter, identity: :counter_uuid
end
