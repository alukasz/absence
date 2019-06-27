defmodule Absence.AbsencesTest do
  use EventSourcing.DispatcherCase, async: true

  import Absence.Factory

  alias Absence.Absences
  alias Absence.Absences.Aggregates.Employee
  alias Absence.Absences.Aggregates.TeamLeader
  alias Absence.Absences.Commands
  alias Absence.Absences.Commands
  alias EventSourcing.UUID

  describe "request_timeoff/0" do
    test "returns chagenset" do
      assert %Ecto.Changeset{} = Absences.request_timeoff()
    end
  end

  describe "request_timeoff/2" do
    setup :employee

    test "with valid params builds and dispatches command", %{user: user} do
      params = string_params_for_command(:request_timeoff)
      employee_uuid = user.employee_uuid
      start_date = params["start_date"]
      end_date = params["end_date"]

      assert :ok = Absences.request_timeoff(user, params)

      assert_dispatched %Commands.RequestTimeoff{
        employee_uuid: ^employee_uuid,
        start_date: ^start_date,
        end_date: ^end_date
      }
    end

    test "with valid params dispatches command Employee aggregate", %{user: user} do
      params = string_params_for_command(:request_timeoff)
      employee_uuid = user.employee_uuid

      assert :ok = Absences.request_timeoff(user, params)

      assert_dispatched Employee, ^employee_uuid, _
    end

    for field <- [:start_date, :end_date] do
      test "#{field} is required", %{user: user} do
        params = string_params_for_command(:request_timeoff, %{unquote(field) => nil})

        assert {:error, changeset} = Absences.request_timeoff(user, params)

        assert "can't be blank" in errors_on(changeset)[unquote(field)]
      end
    end

    test "user is required" do
      params = string_params_for_command(:request_timeoff)

      assert {:error, changeset} = Absences.request_timeoff(build(:user), params)

      assert "can't be blank" in errors_on(changeset).employee_uuid
    end

    test "start_date can be equal to end date", %{user: user} do
      date = ~D[2019-04-10]

      params = string_params_for_command(:request_timeoff, start_date: date, end_date: date)

      assert Absences.request_timeoff(user, params)
    end

    test "start date must be before end date", %{user: user} do
      params =
        string_params_for_command(:request_timeoff,
          start_date: ~D[2019-04-10],
          end_date: ~D[2019-04-09]
        )

      assert {:error, %Ecto.Changeset{} = changeset} = Absences.request_timeoff(user, params)

      assert "must be after start date" in errors_on(changeset).end_date
    end
  end

  describe "approve_timeoff_request/0" do
    test "returns changeset" do
      assert %Ecto.Changeset{} = Absences.approve_timeoff_request()
    end
  end

  describe "approve_timeoff_request/2" do
    setup :team_leader

    test "dispatches command", %{user: user, employee: employee, team_leader: team_leader} do
      team_leader_uuid = team_leader.uuid

      params =
        string_params_for_command(:approve_timeoff_request)
        |> with_employee(employee)
        |> with_timeoff_request()

      assert :ok = Absences.approve_timeoff_request(user, params)

      assert_dispatched TeamLeader, ^team_leader_uuid, %Commands.ApproveTimeoffRequest{}
    end
  end

  describe "reject_timeoff_request/0" do
    test "returns changeset" do
      assert %Ecto.Changeset{} = Absences.reject_timeoff_request()
    end
  end

  describe "reject_timeoff_request/2" do
    setup :team_leader

    test "dispatches command", %{user: user, employee: employee, team_leader: team_leader} do
      team_leader_uuid = team_leader.uuid

      params =
        string_params_for_command(:reject_timeoff_request)
        |> with_employee(employee)
        |> with_timeoff_request()

      assert :ok = Absences.reject_timeoff_request(user, params)

      assert_dispatched TeamLeader, ^team_leader_uuid, %Commands.RejectTimeoffRequest{}
    end
  end

  defp employee(_) do
    employee = %Employee{
      uuid: UUID.generate(),
      team_leader_uuid: UUID.generate()
    }

    start_aggregate(employee)
    user = build(:user) |> with_employee(employee)

    {:ok, user: user, employee: employee}
  end

  def team_leader(_) do
    team_leader = %TeamLeader{
      uuid: UUID.generate()
    }

    start_aggregate(team_leader)

    employee = %Employee{
      uuid: UUID.generate(),
      team_leader_uuid: UUID.generate(),
      team_leader_aggregate_uuid: team_leader.uuid
    }

    start_aggregate(employee)
    user = build(:user) |> with_employee(employee)

    {:ok, user: user, employee: employee, team_leader: team_leader}
  end
end
