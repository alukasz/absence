defmodule AbsenceWeb.RequireGuestTest do
  use AbsenceWeb.ConnCase, async: true

  import Absence.Factory

  alias AbsenceWeb.RequireGuest

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(AbsenceWeb.Router, [:browser])
      |> get("/")

    {:ok, conn: conn}
  end

  describe "call/2 with user not signed in" do
    setup %{conn: conn} do
      {:ok, conn: assign(conn, :current_user, nil)}
    end

    test "returns conn", %{conn: conn} do
      assert RequireGuest.call(conn, []) == conn
    end
  end

  describe "call/2 with user is signed in" do
    setup %{conn: conn} do
      {:ok, conn: assign(conn, :current_user, build(:user))}
    end

    test "halts pipeline", %{conn: conn} do
      assert %{halted: true} = RequireGuest.call(conn, [])
    end

    test "redirects to login page", %{conn: conn} do
      conn = RequireGuest.call(conn, [])

      assert redirected_to_homepage(conn)
    end

    test "sets error flash message", %{conn: conn} do
      conn = RequireGuest.call(conn, [])

      assert get_flash(conn, :info) =~ "You are already authenticated"
    end
  end
end
