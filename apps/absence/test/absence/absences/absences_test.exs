defmodule Absence.AbsencesTest do
  use EventSourcing.AggregateCase, async: true

  import Absence.Factory

  alias Absence.Absences

  describe "request_timeoff/0" do
    test "returns chagenset" do
      assert %Ecto.Changeset{} = Absences.request_timeoff()
    end
  end

  describe "request_timeoff/2" do
    setup do
      {:ok, employee_uuid: EventSourcing.UUID.generate()}
    end

    # TODO consider how to assert success
    test "with valid params", %{employee_uuid: employee_uuid} do
      params = string_params_for_command(:request_timeoff)

      assert Absences.request_timeoff(employee_uuid, params)
    end

    for field <- [:start_date, :end_date] do
      test "#{field} is required", %{employee_uuid: employee_uuid} do
        params = string_params_for_command(:request_timeoff, %{unquote(field) => nil})

        assert {:error, changeset} = Absences.request_timeoff(employee_uuid, params)

        assert "can't be blank" in errors_on(changeset)[unquote(field)]
      end
    end

    test "employee_uuid is required" do
      params = string_params_for_command(:request_timeoff)

      assert {:error, changeset} = Absences.request_timeoff("", params)

      assert "can't be blank" in errors_on(changeset).employee_uuid
    end

    test "start_date can be equal to end date", %{employee_uuid: employee_uuid} do
      date = ~D[2019-04-10]

      params = string_params_for_command(:request_timeoff, start_date: date, end_date: date)

      assert Absences.request_timeoff(employee_uuid, params)
    end

    test "start date must be before end date", %{employee_uuid: employee_uuid} do
      params =
        string_params_for_command(:request_timeoff,
          start_date: ~D[2019-04-10],
          end_date: ~D[2019-04-09]
        )

      assert {:error, %Ecto.Changeset{} = changeset} =
               Absences.request_timeoff(employee_uuid, params)

      assert "must be after start date" in errors_on(changeset).end_date
    end
  end
end
