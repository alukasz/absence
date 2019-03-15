{:ok, _} = EventSourcing.EventStore.AgentEventStore.start_link([])

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(EventSourcing.EventStore.Repo, :manual)
