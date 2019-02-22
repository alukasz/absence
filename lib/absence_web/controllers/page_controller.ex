defmodule AbsenceWeb.PageController do
  use AbsenceWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
