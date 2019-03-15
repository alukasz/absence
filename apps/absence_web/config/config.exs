# Since configuration is shared in umbrella projects, this file
# should only configure the :absence_web application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# General application configuration
config :absence_web,
  ecto_repos: [EventSourcing.EventStore.Repo],
  generators: [context_app: :absence, binary_id: true]

# Configures the endpoint
config :absence_web, AbsenceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "CVUWAXv+A6Xv7mFOAhVQf6XHiZREN5DNQz48UWqb9sDEdWb7ED5CBvVUXNwm6iD4",
  render_errors: [view: AbsenceWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: AbsenceWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
