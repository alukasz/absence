use Mix.Config

config :event_sourcing, ecto_repos: [EventSourcing.EventStore.Repo]

config :event_sourcing, event_store: EventSourcing.EventStore.EctoEventStore

config :event_sourcing, uuid_generator: EventSourcing.UUID

import_config "#{Mix.env()}.exs"
