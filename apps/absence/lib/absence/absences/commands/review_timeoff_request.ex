defmodule Absence.Absences.Commands.ReviewTimeoffRequest do
  defstruct [
    :uuid,
    :team_leader_uuid,
    :timeoff_request
  ]
end
