use Mix.Config

# Print only warnings and errors during test
config :logger, level: :warn

config :argon2_elixir,
  t_cost: 1,
  m_cost: 8
