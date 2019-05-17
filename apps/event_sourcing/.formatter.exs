locals_without_parens = [
  # EventSourcing.Dispatcher
  dispatch: 2,
  # EventSourcing.EventHandler
  handle: 2,
  handle: 3,
  # EventSourcing.Command
  field: 2,
  field: 3,
  # EventSourcing.AggregateCase
  assert_dispatched: 1,
  assert_dispatched: 3
]

[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: locals_without_parens,
  export: [
    locals_without_parens: locals_without_parens
  ]
]
