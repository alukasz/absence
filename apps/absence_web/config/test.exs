# Since configuration is shared in umbrella projects, this file
# should only configure the :absence_web application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :absence_web,
  accounts: Absence.AccountsMock

config :absence_web, AbsenceWeb.Endpoint,
  http: [port: 4002],
  server: false

config :argon2_elixir,
  t_cost: 1,
  m_cost: 8
