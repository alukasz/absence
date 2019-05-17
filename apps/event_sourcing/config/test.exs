use Mix.Config

config :event_sourcing,
  event_store: EventSourcing.EventStore.AgentEventStore,
  uuid_generator: EventSourcing.FakeUUID,
  dispatcher: EventSourcing.FakeDispatcher
