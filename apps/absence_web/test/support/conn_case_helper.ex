defmodule AbsenceWeb.ConnCaseHelper do
  import ExUnit.Assertions, only: [assert: 1, assert: 2]
  import Phoenix.ConnTest, only: [redirected_to: 1]
  import Mox

  alias Absence.Absences.Aggregates.Employee
  alias Absence.Absences.Aggregates.TeamLeader
  alias Absence.AbsencesMock
  alias Absence.Accounts.User
  alias Absence.Factory
  alias AbsenceWeb.Router.Helpers
  alias Plug.Conn

  def current_user(conn) do
    conn.assigns.current_user
  end

  def authenticate(%{conn: conn} = _context) do
    {:ok, conn: authenticate(conn)}
  end

  def authenticate(conn, %User{} = user \\ Factory.build(:user)) do
    Conn.assign(conn, :current_user, user)
  end

  def employee(conn_or_context \\ %{})

  def employee(%{conn: conn} = _context) do
    {:ok, conn: employee(conn)}
  end

  def employee(conn) do
    stub(AbsencesMock, :get_employee, fn _ -> %Employee{} end)
    conn
  end

  def employee_team_leader(conn_or_context \\ %{})

  def employee_team_leader(%{conn: conn} = _context) do
    {:ok, conn: employee_team_leader(conn)}
  end

  def employee_team_leader(conn) do
    stub(AbsencesMock, :get_employee_team_leader, fn _ -> %TeamLeader{} end)
    conn
  end

  def team_leader(conn_or_context \\ %{})

  def team_leader(%{conn: conn}) do
    {:ok, conn: team_leader(conn)}
  end

  def team_leader(conn) do
    stub(AbsencesMock, :get_team_leader, fn _ -> %TeamLeader{} end)
    conn
  end

  def redirected_to_homepage(conn) do
    assert redirected_to(conn) =~ Helpers.timeoff_path(conn, :index)
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
