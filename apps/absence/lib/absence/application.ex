defmodule Absence.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Absence.Repo
    ]

    # bamboozled by elixir compilation
    # registering event handlers during compilation in handle/2,3 macro works great
    # as long as the module is compiled, which it usually isn't since it gets cached
    # manually register handlers here until it's fixed
    alias Absence.Absences.Events.TimeoffRequested
    alias Absence.Absences.EventHandlers.TimeoffEventHandler
    EventSourcing.EventHandler.register_handler(TimeoffRequested, TimeoffEventHandler)

    opts = [strategy: :one_for_one, name: Absence.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
