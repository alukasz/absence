defmodule AbsenceWeb.RegistrationControllerTest do
  use AbsenceWeb.ConnCase

  import Routes, only: [registration_path: 2, page_path: 2]

  @email "registration@example.com"
  @password "P@ssw0rd"

  describe "#new" do
    test "renders registration form", %{conn: conn} do
      conn = get(conn, registration_path(conn, :new))

      assert html_response(conn, 200) =~ "Registration"
      assert html_response(conn, 200) =~ "Email"
      assert html_response(conn, 200) =~ "Password"
      assert html_response(conn, 200) =~ "Repeat password"
      assert html_response(conn, 200) =~ "Register"
    end
  end

  describe "#create" do
    test "creates a new user", %{conn: conn} do
      conn =
        post conn, registration_path(conn, :create), %{
          user: %{
            first_name: "John",
            last_name: "Doe",
            email: @email,
            password: @password,
            password_confirmation: @password
          }
        }

      assert redirected_to(conn) == page_path(conn, :index)
      assert get_flash(conn, :info) =~ "Registration successful"
    end
  end
end
