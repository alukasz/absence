defmodule Absence.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Absence.Repo,
      AbsenceWeb.Endpoint,
      EventSourcing.Supervisor
    ]

    opts = [strategy: :one_for_one, name: Absence.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    AbsenceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
