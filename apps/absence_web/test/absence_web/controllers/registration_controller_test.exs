defmodule AbsenceWeb.RegistrationControllerTest do
  use AbsenceWeb.ConnCase, async: true

  import Routes, only: [registration_path: 2, page_path: 2]
  import Mox

  alias Absence.AccountsMock
  alias Absence.Accounts.User
  alias Ecto.Changeset

  @email "registration@example.com"
  @password "P@ssw0rd"
  @valid_params %{
    "first_name" => "John",
    "last_name" => "Doe",
    "email" => @email,
    "password" => @password,
    "password_confirmation" => @password
  }

  setup :verify_on_exit!

  describe "#new" do
    test "renders registration form", %{conn: conn} do
      expect(AccountsMock, :user_changeset, 1, fn -> Changeset.change(%User{}) end)

      conn = get(conn, registration_path(conn, :new))

      assert html_response(conn, 200) =~ "Registration"
      assert html_response(conn, 200) =~ "Email"
      assert html_response(conn, 200) =~ "Password"
      assert html_response(conn, 200) =~ "Repeat password"
      assert html_response(conn, 200) =~ "Register"
    end
  end

  describe "#create with valid params" do
    test "creates a new user", %{conn: conn} do
      expect(AccountsMock, :register, 1, fn @valid_params -> {:ok, %User{}} end)

      conn = post(conn, registration_path(conn, :create), %{user: @valid_params})

      assert redirected_to(conn) == page_path(conn, :index)
      assert get_flash(conn, :info) =~ "Registration successful"
    end
  end

  describe "#create with invalid params" do
    setup do
      {_, changeset} =
        %User{}
        |> Changeset.change()
        |> Changeset.add_error(:first_name, "can't be blank")
        |> Changeset.add_error(:password_confirmation, "does not match confirmation")
        |> Changeset.apply_action(:insert)

      expect(AccountsMock, :register, 1, fn _ -> {:error, changeset} end)

      :ok
    end

    test "renders registration form", %{conn: conn} do
      conn = post(conn, registration_path(conn, :create), %{user: %{}})

      assert html_response(conn, 200) =~ "Registration"
    end

    test "renders form errors", %{conn: conn} do
      conn = post(conn, registration_path(conn, :create), %{user: %{}})

      assert html_response(conn, 200) =~ "does not match confirmation"
      assert html_response(conn, 200) =~ escape_string("can't be blank")
    end
  end
end
