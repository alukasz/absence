defmodule AbsenceWeb.SessionControllerTest do
  use AbsenceWeb.ConnCase, async: true

  import Routes, only: [session_path: 2, page_path: 2]
  import Mox

  alias Absence.AccountsMock
  alias Absence.Accounts.User

  @params Absence.Factory.string_params_for(:user) |> Map.take(["email", "password"])
  @user_id 42

  describe "#new" do
    test "renders login form", %{conn: conn} do
      conn = get(conn, session_path(conn, :new))

      assert html_response(conn, 200) =~ "Log in"
      assert html_response(conn, 200) =~ "Email"
      assert html_response(conn, 200) =~ "Password"
    end
  end

  describe "#create with valid email/password" do
    setup :verify_on_exit!

    setup do
      expect(AccountsMock, :authenticate_email_password, 1, fn _, _ ->
        {:ok, %User{id: @user_id}}
      end)

      :ok
    end

    test "redirects to home page", %{conn: conn} do
      conn = post(conn, session_path(conn, :create), %{session: @params})

      assert redirected_to(conn) =~ page_path(conn, :index)
    end

    test "puts token in session", %{conn: conn} do
      conn = post(conn, session_path(conn, :create), %{session: @params})

      token = get_session(conn, :user_id)

      assert {:ok, @user_id} =
               Phoenix.Token.verify(AbsenceWeb.Endpoint, "session", token, max_age: 24 * 60 * 60)
    end
  end

  describe "#create with invalid email/password" do
    setup :verify_on_exit!

    setup do
      expect(AccountsMock, :authenticate_email_password, 1, fn _, _ -> :error end)

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
