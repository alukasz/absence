defmodule Absence.Absences.Commands.RejectTimeoffRequest do
  defstruct [
    :uuid,
    :employee_uuid,
    :team_leader_uuid,
    :timeoff_request
  ]
end
