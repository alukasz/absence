defmodule AbsenceWeb.TimeoffController do
  use AbsenceWeb, :controller

  @absences Application.get_env(:absence_web, :absences)
  @dummy_uuid "b2f7d83d-64a3-4663-acd1-8c63170d2d3b"

  plug AbsenceWeb.RequireUser
  plug :scrub_params, "timeoff_request" when action == :create

  def index(conn, _) do
    render(conn, "index.html")
  end

  def new(conn, _) do
    render(conn, "new.html", timeoff_request: @absences.request_timeoff())
  end

  def create(conn, %{"timeoff_request" => params}) do
    # TODO associate employee with user, pass employee uuid
    case @absences.request_timeoff(@dummy_uuid, params) do
      {:error, changeset} ->
        render(conn, "new.html", timeoff_request: changeset)

      _ ->
        conn
        |> put_flash(:info, "Timeoff requested")
        |> redirect(to: Routes.timeoff_path(conn, :index))
    end
  end
end
