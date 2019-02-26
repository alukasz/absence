ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Absence.Repo, :manual)

{:ok, _} = EventSourcing.EventStore.AgentEventStore.start_link([])
