defmodule AbsenceWeb.SessionControllerTest do
  use AbsenceWeb.ConnCase, async: true

  import Routes, only: [session_path: 2]
  import Mox

  alias Absence.AccountsMock
  alias Absence.Accounts.User

  @email "test@example.com"
  @password "P@ssw0rd"
  @params %{
    "email" => @email,
    "password" => @password
  }
  @user_id 42

  describe "#new" do
    test "renders login form", %{conn: conn} do
      conn = get(conn, session_path(conn, :new))

      assert html_response(conn, 200) =~ "Log in"
      assert html_response(conn, 200) =~ "Email"
      assert html_response(conn, 200) =~ "Password"
    end

    test "redirects to home page when user is authenticated", %{conn: conn} do
      conn = authenticate(conn)

      conn = get(conn, session_path(conn, :new))

      assert redirected_to_homepage(conn)
    end
  end

  describe "#create" do
    test "redirects to home page when user is authenticated", %{conn: conn} do
      conn = authenticate(conn)

      conn = post(conn, session_path(conn, :create), %{session: %{}})

      assert redirected_to_homepage(conn)
    end
  end

  describe "#create with valid email/password" do
    setup :verify_on_exit!

    setup do
      expect(AccountsMock, :authenticate_email_password, 1, fn @email, @password ->
        {:ok, %User{id: @user_id}}
      end)

      :ok
    end

    test "redirects to home page", %{conn: conn} do
      conn = post(conn, session_path(conn, :create), %{session: @params})

      assert redirected_to_homepage(conn)
    end

    test "puts token in session", %{conn: conn} do
      conn = post(conn, session_path(conn, :create), %{session: @params})

      token = get_session(conn, :user_id)

      assert {:ok, @user_id} = AbsenceWeb.Authenticator.decrypt(token)
    end
  end

  describe "#create with invalid email/password" do
    setup :verify_on_exit!

    setup do
      expect(AccountsMock, :authenticate_email_password, 1, fn @email, @password ->
        :error
      end)

      :ok
    end

    test "renders login form", %{conn: conn} do
      conn = post(conn, session_path(conn, :create), %{session: @params})

      assert html_response(conn, 200) =~ "Log in"
      assert html_response(conn, 200) =~ "Email"
      assert html_response(conn, 200) =~ "Password"
    end

    test "renders error message", %{conn: conn} do
      conn = post(conn, session_path(conn, :create), %{session: @params})

      assert html_response(conn, 200) =~ "Invalid email/password"
    end
  end
end
