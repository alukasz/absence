defmodule Absence.Application do
  @moduledoc false

  use Application

  alias Absence.Absences.EventHandlers.TimeoffEventHandler

  def start(_type, _args) do
    children = [
      Absence.Repo
    ]

    EventSourcing.EventHandler.register_handler(TimeoffEventHandler)

    opts = [strategy: :one_for_one, name: Absence.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
