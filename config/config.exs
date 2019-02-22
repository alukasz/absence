# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :absence,
  ecto_repos: [Absence.Repo]

# Configures the endpoint
config :absence, AbsenceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "VPBX431o72TKeWLis3YESGxoDNCVJrsSH8K4xc33eYmPXA5IT8TBtUfIJsbwjxn1",
  render_errors: [view: AbsenceWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Absence.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
