defmodule AbsenceWeb.Admin.TimeoffController do
  use AbsenceWeb, :controller

  @absences Application.get_env(:absence_web, :absences)

  plug AbsenceWeb.RequireUser
  plug AbsenceWeb.AuthorizePlug, AbsenceWeb.Admin.TimeoffPolicy
  plug :scrub_params, "timeoff_request" when action == :create

  def index(conn, _) do
    render(conn, "index.html",
      timeoff_requests: @absences.get_team_leader_timeoff_requests(current_user(conn)),
      approve_changeset: @absences.approve_timeoff_request(),
      reject_changeset: @absences.reject_timeoff_request()
    )
  end

  def update(conn, %{"approve_timeoff_request" => params}) do
    :ok = @absences.approve_timeoff_request(current_user(conn), params)

    conn
    |> put_flash(:info, "Timeoff accepted")
    |> redirect(to: Routes.admin_timeoff_path(conn, :index))
  end

  def update(conn, %{"reject_timeoff_request" => params}) do
    :ok = @absences.reject_timeoff_request(current_user(conn), params)

    conn
    |> put_flash(:info, "Timeoff rejected")
    |> redirect(to: Routes.admin_timeoff_path(conn, :index))
  end
end
