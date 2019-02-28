defmodule AbsenceWeb.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      AbsenceWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: AbsenceWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    AbsenceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
