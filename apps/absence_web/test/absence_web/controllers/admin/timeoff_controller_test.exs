defmodule AbsenceWeb.Admin.TimeoffControllerTest do
  use AbsenceWeb.ConnCase, async: true

  import Absence.Factory

  import Routes, only: [admin_timeoff_path: 2]
  import Mox

  alias Absence.AbsencesMock
  alias Absence.Absences.Commands

  setup :verify_on_exit!

  defp timeoff_request(status) do
    timeoff_request = build_entity(:timeoff_request, status: status)

    expect(AbsencesMock, :get_team_leader_timeoff_requests, fn _ ->
      [timeoff_request]
    end)

    expect(AbsencesMock, :approve_timeoff_request, fn ->
      Commands.ApproveTimeoffRequest.changeset()
    end)

    expect(AbsencesMock, :reject_timeoff_request, fn ->
      Commands.RejectTimeoffRequest.changeset()
    end)

    timeoff_request
  end

  describe "#index" do
    test "renders team leader's timeoff requests", %{conn: conn} do
      conn = conn |> authenticate() |> team_leader()
      timeoff_request(:approved)

      conn = get(conn, admin_timeoff_path(conn, :index))

      assert html_response(conn, 200) =~ "Timeoff requests"
      assert html_response(conn, 200) =~ "approved"
    end

    test "shows buttons for pending timeoff request", %{conn: conn} do
      conn = conn |> authenticate() |> team_leader()
      timeoff_request(:pending)

      conn = get(conn, admin_timeoff_path(conn, :index))

      assert html_response(conn, 200) =~ "Approve"
      assert html_response(conn, 200) =~ "Reject"
    end

    test "does not show buttons for approved timeoff request", %{conn: conn} do
      conn = conn |> authenticate() |> team_leader()
      timeoff_request(:approved)

      conn = get(conn, admin_timeoff_path(conn, :index))

      refute html_response(conn, 200) =~ "Approve"
      refute html_response(conn, 200) =~ "Reject"
    end

    test "does not show buttons for rejected timeoff request", %{conn: conn} do
      conn = conn |> authenticate() |> team_leader()
      timeoff_request(:rejected)

      conn = get(conn, admin_timeoff_path(conn, :index))

      refute html_response(conn, 200) =~ "Approve"
      refute html_response(conn, 200) =~ "Reject"
    end

    test "redirects to login page when user is not authenticated", %{conn: conn} do
      conn = get(conn, admin_timeoff_path(conn, :index))

      assert redirected_to_login_page(conn)
      assert get_flash(conn, :error) =~ "authenticated"
    end

    test "redirects to login page when user is not team leader", %{conn: conn} do
      conn = authenticate(conn)
      stub(AbsencesMock, :get_team_leader, fn _ -> nil end)

      conn = get(conn, admin_timeoff_path(conn, :index))

      assert redirected_to_homepage(conn)
      assert get_flash(conn, :error) =~ "authorized"
    end
  end

  def changeset(:approve) do
    Ecto.Changeset.change(Commands.ApproveTimeoffRequest.__schema__())
  end

  def changeset(:reject) do
    Ecto.Changeset.change(Commands.RejectTimeoffRequest.__schema__())
  end
end
