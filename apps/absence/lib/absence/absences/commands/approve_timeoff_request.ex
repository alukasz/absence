defmodule Absence.Absences.Commands.ApproveTimeoffRequest do
  use EventSourcing.Command

  command do
    field :employee_uuid, EventSourcing.UUID
    field :team_leader_uuid, EventSourcing.UUID
    field :timeoff_request_uuid, EventSourcing.UUID
  end
end
