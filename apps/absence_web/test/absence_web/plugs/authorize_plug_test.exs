defmodule AbsenceWeb.AuthorizePlugTest do
  use AbsenceWeb.ConnCase, async: true

  alias AbsenceWeb.AuthorizePlug
  alias Absence.Accounts.User
  alias Plug.Conn

  @resource :resource

  defmodule Policy do
    def index(%User{}), do: true

    def index(_), do: false

    def index(_, :pass), do: true

    def index(_, :fail), do: false
  end

  setup %{conn: conn} do
    conn =
      conn
      |> Plug.Test.init_test_session(%{})
      |> bypass_through(AbsenceWeb.Router, [:browser])
      |> get("/")
      |> Conn.put_private(:phoenix_action, :index)

    {:ok, conn: conn}
  end

  describe "call/2 with policy" do
    test "when policy pass returns conn", %{conn: conn} do
      conn = with_current_user(conn)

      assert AuthorizePlug.call(conn, Policy) == conn
    end

    test "halts when policy fails", %{conn: conn} do
      conn = AuthorizePlug.call(conn, Policy)

      assert conn.halted
    end

    test "redirects when policy fails", %{conn: conn} do
      conn = AuthorizePlug.call(conn, Policy)

      assert redirected_to_homepage(conn)
    end

    test "puts flash message when policy fails", %{conn: conn} do
      conn = AuthorizePlug.call(conn, Policy)

      assert get_flash(conn, :error) =~ "You are not authorized to access this page"
    end
  end

  describe "call/2 with policy and resource" do
    test "when policy pass returns conn", %{conn: conn} do
      conn = with_resource(conn, :pass)

      assert AuthorizePlug.call(conn, [Policy, @resource]) == conn
    end

    test "halts when policy fails", %{conn: conn} do
      conn = with_resource(conn, :fail)

      conn = AuthorizePlug.call(conn, [Policy, @resource])

      assert conn.halted
    end

    test "redirects when policy fails", %{conn: conn} do
      conn = with_resource(conn, :fail)

      conn = AuthorizePlug.call(conn, [Policy, @resource])

      assert redirected_to_homepage(conn)
    end

    test "puts flash message when policy fails", %{conn: conn} do
      conn = with_resource(conn, :fail)

      conn = AuthorizePlug.call(conn, [Policy, @resource])

      assert get_flash(conn, :error) =~ "You are not authorized to access this page"
    end
  end

  defp with_current_user(conn) do
    Conn.assign(conn, :current_user, %User{})
  end

  defp with_resource(conn, resource) do
    Conn.assign(conn, @resource, resource)
  end
end
