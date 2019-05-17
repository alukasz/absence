defmodule AbsenceWeb.ConnCaseHelper do
  import ExUnit.Assertions, only: [assert: 1, assert: 2]
  import Phoenix.ConnTest, only: [redirected_to: 1]

  alias Absence.Factory
  alias Plug.Conn
  alias AbsenceWeb.Router.Helpers

  def authenticate(conn, user \\ Factory.build(:user)) do
    Conn.assign(conn, :current_user, user)
  end

  def current_user(conn) do
    conn.assigns.current_user
  end

  def redirected_to_homepage(conn) do
    assert redirected_to(conn) =~ Helpers.page_path(conn, :index)
  end

  def redirected_to_login_page(conn) do
    assert redirected_to(conn) =~ Helpers.session_path(conn, :new)
  end

  def escape_string(string) do
    string
    |> Phoenix.HTML.html_escape()
    |> Phoenix.HTML.safe_to_string()
  end
end
