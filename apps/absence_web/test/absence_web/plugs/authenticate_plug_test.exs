defmodule AbsenceWeb.AuthenticatePlugTest do
  use AbsenceWeb.ConnCase, async: true

  import Mox

  alias AbsenceWeb.AuthenticatePlug
  alias Absence.AccountsMock
  alias Absence.Accounts.User

  @user_id 42

  setup :verify_on_exit!

  describe "call/2 when current_user is already assigned" do
    setup %{conn: conn} do
      conn = assign(conn, :current_user, %User{id: @user_id})

      {:ok, conn: conn}
    end

    test "returns unmodified conn", %{conn: conn} do
      assert AuthenticatePlug.call(conn, []) == conn
    end
  end

  describe "call/2 with valid token" do
    setup %{conn: conn} do
      token = AbsenceWeb.Authenticator.encrypt(@user_id)
      conn = Plug.Test.init_test_session(conn, %{user_id: token})
      user = %User{id: @user_id}

      {:ok, conn: conn, user: user}
    end

    test "assigns user to conn as current_user", %{conn: conn, user: user} do
      expect(AccountsMock, :get_user, 1, fn @user_id -> user end)

      assert %{assigns: %{current_user: ^user}} = AuthenticatePlug.call(conn, [])
    end
  end

  describe "call/2 with invalid token" do
    setup %{conn: conn} do
      token = "invalid token"
      conn = Plug.Test.init_test_session(conn, %{user_id: token})
      user = %User{id: @user_id}

      {:ok, conn: conn, user: user}
    end

    test "assigns nil as current_user", %{conn: conn, user: user} do
      expect(AccountsMock, :get_user, 0, fn @user_id -> user end)

      assert %{assigns: %{current_user: nil}} = AuthenticatePlug.call(conn, [])
    end
  end

  describe "call/2 with missing token" do
    setup %{conn: conn} do
      conn = Plug.Test.init_test_session(conn, %{})
      user = %User{id: @user_id}

      {:ok, conn: conn, user: user}
    end

    test "assigns nil as current_user", %{conn: conn, user: user} do
      expect(AccountsMock, :get_user, 0, fn @user_id -> user end)

      assert %{assigns: %{current_user: nil}} = AuthenticatePlug.call(conn, [])
    end
  end
end
