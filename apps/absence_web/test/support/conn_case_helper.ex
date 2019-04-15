defmodule AbsenceWeb.ConnCaseHelper do
  alias Absence.Factory
  alias Plug.Conn

  def authenticate(conn, user \\ Factory.build(:user)) do
    Conn.assign(conn, :current_user, user)
  end

  def escape_string(string) do
    string
    |> Phoenix.HTML.html_escape()
    |> Phoenix.HTML.safe_to_string()
  end
end
