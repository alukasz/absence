defmodule AbsenceWeb.RequireUserTest do
  use AbsenceWeb.ConnCase, async: true

  import Absence.Factory
  import AbsenceWeb.Router.Helpers, only: [session_path: 2]

  alias AbsenceWeb.RequireUser

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(AbsenceWeb.Router, [:browser])
      |> get("/")

    {:ok, conn: conn}
  end

  describe "call/2 with user signed in" do
    setup %{conn: conn} do
      {:ok, conn: assign(conn, :current_user, build(:user))}
    end

    test "returns conn", %{conn: conn} do
      assert RequireUser.call(conn, []) == conn
    end
  end

  describe "call/2 with user is not signed in" do
    setup %{conn: conn} do
      {:ok, conn: assign(conn, :current_user, nil)}
    end

    test "halts pipeline", %{conn: conn} do
      assert %{halted: true} = RequireUser.call(conn, [])
    end

    test "reidrects to login page", %{conn: conn} do
      conn = RequireUser.call(conn, [])

      assert redirected_to(conn) == session_path(conn, :new)
    end

    test "sets error flash message", %{conn: conn} do
      conn = RequireUser.call(conn, [])

      assert get_flash(conn, :error) =~ "You must be authenticated"
    end
  end
end
