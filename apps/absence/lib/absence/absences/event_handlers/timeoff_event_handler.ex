defmodule Absence.Absences.EventHandlers.TimeoffEventHandler do
  use EventSourcing.EventHandler

  alias Absence.Absences.Aggregates.Employee
  alias Absence.Absences.Aggregates.TeamLeader
  alias Absence.Absences.Commands.ReviewTimeoffRequest
  alias Absence.Absences.Commands.ApproveTimeoffRequest
  alias Absence.Absences.Commands.RejectTimeoffRequest
  alias Absence.Absences.Events.TimeoffRequested
  alias Absence.Absences.Events.TimeoffRequestApproved
  alias Absence.Absences.Events.TimeoffRequestRejected
  alias Absence.Dispatcher

  handle %TimeoffRequested{} = event, %Employee{} = employee do
    :ok =
      Dispatcher.dispatch(%ReviewTimeoffRequest{
        team_leader_uuid: employee.team_leader_uuid,
        timeoff_request: event.timeoff_request
      })
  end

  handle %TimeoffRequestApproved{}, %Employee{}, do: :ok

  handle %TimeoffRequestApproved{} = event, %TeamLeader{} do
    command = %ApproveTimeoffRequest{
      employee_uuid: event.employee_uuid,
      team_leader_uuid: event.team_leader_uuid,
      timeoff_request_uuid: event.timeoff_request.uuid
    }

    :ok = Dispatcher.dispatch(command, to: Employee, identity: :employee_uuid)
  end

  handle %TimeoffRequestRejected{}, %Employee{}, do: :ok

  handle %TimeoffRequestRejected{} = event, %TeamLeader{} do
    command = %RejectTimeoffRequest{
      employee_uuid: event.employee_uuid,
      team_leader_uuid: event.team_leader_uuid,
      timeoff_request_uuid: event.timeoff_request.uuid
    }

    :ok = Dispatcher.dispatch(command, to: Employee, identity: :employee_uuid)
  end
end
