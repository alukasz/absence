# Since configuration is shared in umbrella projects, this file
# should only configure the :absence application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# Configure your database
config :absence, Absence.Repo,
  username: "postgres",
  password: "postgres",
  database: "absence_dev",
  hostname: "localhost",
  pool_size: 10
