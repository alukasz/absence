defmodule AbsenceWeb.Admin.TimeoffController do
  use AbsenceWeb, :controller

  @absences Application.get_env(:absence_web, :absences)

  plug AbsenceWeb.RequireUser
  plug AbsenceWeb.AuthorizePlug, AbsenceWeb.Admin.TimeoffPolicy
  plug :scrub_params, "timeoff_request" when action == :create

  def index(conn, _) do
    # timeoff_requests = @absences.get_team_leader_timeoff_requests(current_user(conn))
    timeoff_requests = @absences.get_timeoff_requests(current_user(conn))

    render(conn, "index.html", timeoff_requests: timeoff_requests)
  end
end
