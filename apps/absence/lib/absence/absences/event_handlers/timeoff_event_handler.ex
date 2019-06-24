defmodule Absence.Absences.EventHandlers.TimeoffEventHandler do
  use EventSourcing.EventHandler

  alias Absence.Absences.Aggregates.Employee
  alias Absence.Absences.Commands.ReviewTimeoffRequest
  alias Absence.Absences.Events.TimeoffRequested
  alias Absence.Dispatcher

  handle %TimeoffRequested{} = event, %Employee{} = employee do
    %ReviewTimeoffRequest{
      team_leader_uuid: employee.team_leader_uuid,
      timeoff_request: event.timeoff_request
    }
    |> Dispatcher.dispatch()
  end
end
