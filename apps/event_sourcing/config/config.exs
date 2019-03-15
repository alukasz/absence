use Mix.Config

config :event_sourcing, ecto_repos: [EventSourcing.EventStore.Repo]

config :event_sourcing, event_store: EventSourcing.EventStore.EctoEventStore

import_config "#{Mix.env()}.exs"
