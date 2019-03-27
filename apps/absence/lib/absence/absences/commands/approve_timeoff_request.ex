defmodule Absence.Absences.Commands.ApproveTimeoffRequest do
  defstruct [
    :uuid,
    :employee_uuid,
    :team_leader_uuid,
    :timeoff_request
  ]
end
