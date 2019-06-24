defmodule Absence.Absences.Events.TimeoffReviewRequested do
  @derive Jason.Encoder

  defstruct [
    :uuid,
    :team_leader_uuid,
    :timeoff_request
  ]
end
