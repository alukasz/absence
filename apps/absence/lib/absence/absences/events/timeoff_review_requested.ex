defmodule Absence.Absences.Events.TimeoffReviewRequested do
  defstruct [
    :uuid,
    :team_leader_uuid,
    :timeoff_request
  ]
end
