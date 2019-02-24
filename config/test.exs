use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :absence, AbsenceWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :absence, Absence.Repo,
  username: "postgres",
  password: "postgres",
  database: "absence_test",
  hostname: "0.0.0.0",
  pool: Ecto.Adapters.SQL.Sandbox
