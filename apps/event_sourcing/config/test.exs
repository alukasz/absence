use Mix.Config

config :event_sourcing, event_store: EventSourcing.EventStore.AgentEventStore

config :event_sourcing, uuid_generator: EventSourcing.FakeUUID
