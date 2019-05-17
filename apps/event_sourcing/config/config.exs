use Mix.Config

config :event_sourcing,
  ecto_repos: [EventSourcing.EventStore.Repo],
  event_store: EventSourcing.EventStore.EctoEventStore,
  uuid_generator: EventSourcing.UUID,
  dispatcher: EventSourcing.Dispatcher

import_config "#{Mix.env()}.exs"
