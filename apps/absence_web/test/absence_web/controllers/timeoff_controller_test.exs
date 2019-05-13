defmodule AbsenceWeb.TimeoffControllerTest do
  use AbsenceWeb.ConnCase, async: true

  import Routes, only: [timeoff_path: 2]
  import Mox

  alias Absence.AbsencesMock
  alias Absence.Absences.Commands

  setup :verify_on_exit!

  @valid_params %{"end_date" => "2019-05-13", "start_date" => "2019-05-17"}

  describe "#new" do
    test "renders registration form", %{conn: conn} do
      expect(AbsencesMock, :request_timeoff, 1, fn -> changeset() end)
      conn = authenticate(conn)

      conn = get(conn, timeoff_path(conn, :new))

      assert html_response(conn, 200) =~ "Request timeoff"
      assert html_response(conn, 200) =~ "Start date"
      assert html_response(conn, 200) =~ "End date"
      assert html_response(conn, 200) =~ "Submit"
    end

    test "redirects to login page when user is not authenticated", %{conn: conn} do
      conn = get(conn, timeoff_path(conn, :new))

      assert redirected_to_login_page(conn)
    end
  end

  describe "#create" do
    test "with valid params redirects to #index page", %{conn: conn} do
      expect(AbsencesMock, :request_timeoff, 1, fn _, @valid_params -> :ok end)
      conn = authenticate(conn)

      conn = post(conn, timeoff_path(conn, :create), %{timeoff_request: @valid_params})

      assert redirected_to(conn) =~ timeoff_path(conn, :index)
    end

    test "with valid params puts success flass message", %{conn: conn} do
      expect(AbsencesMock, :request_timeoff, 1, fn _, @valid_params -> :ok end)
      conn = authenticate(conn)

      conn = post(conn, timeoff_path(conn, :create), %{timeoff_request: @valid_params})

      assert get_flash(conn, :info) =~ "Timeoff requested"
    end

    test "with invalid params renders form", %{conn: conn} do
      expect(AbsencesMock, :request_timeoff, 1, fn _, _ -> {:error, changeset()} end)

      conn = authenticate(conn)

      conn = post(conn, timeoff_path(conn, :create), %{timeoff_request: %{}})

      assert html_response(conn, 200) =~ "Request timeoff"
      assert html_response(conn, 200) =~ "Submit"
    end

    test "redirects to login page when user is not authenticated", %{conn: conn} do
      conn = get(conn, timeoff_path(conn, :new))

      assert redirected_to_login_page(conn)
    end
  end

  def changeset do
    Ecto.Changeset.change(Commands.RequestTimeoff.__schema__())
  end
end
