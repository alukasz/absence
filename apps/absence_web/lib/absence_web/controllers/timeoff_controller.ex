defmodule AbsenceWeb.TimeoffController do
  use AbsenceWeb, :controller

  @absences Application.get_env(:absence_web, :absences)

  plug AbsenceWeb.RequireUser
  plug :scrub_params, "timeoff_request" when action == :create

  def index(conn, _) do
    timeoff_requests = @absences.get_timeoff_requests(current_user(conn))

    render(conn, "index.html", timeoff_requests: timeoff_requests)
  end

  def new(conn, _) do
    render(conn, "new.html", timeoff_request: @absences.request_timeoff())
  end

  def create(conn, %{"timeoff_request" => params}) do
    case @absences.request_timeoff(current_user(conn), params) do
      {:error, changeset} ->
        render(conn, "new.html", timeoff_request: changeset)

      _ ->
        conn
        |> put_flash(:info, "Timeoff requested")
        |> redirect(to: Routes.timeoff_path(conn, :index))
    end
  end
end
