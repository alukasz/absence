# Since configuration is shared in umbrella projects, this file
# should only configure the :absence application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

config :absence, ecto_repos: [Absence.Repo]

import_config "#{Mix.env()}.exs"
