defmodule Absence.Repo do
  use Ecto.Repo,
    otp_app: :absence,
    adapter: Ecto.Adapters.Postgres
end
