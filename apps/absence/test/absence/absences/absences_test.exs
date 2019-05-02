defmodule Absence.AbsencesTest do
  use EventSourcing.AggregateCase, async: true

  import Absence.Factory

  alias Absence.Absences

  describe "request_timeoff/1" do
    # TODO consider how to assert success
    test "with valid params" do
      params = params_for_command(:request_timeoff) |> with_employee()

      assert Absences.request_timeoff(params)
    end

    for field <- [:start_date, :end_date] do
      test "#{field} is required" do
        params =
          params_for_command(:request_timeoff, %{unquote(field) => nil})
          |> with_employee()

        assert {:error, changeset} = Absences.request_timeoff(params)

        assert "can't be blank" in errors_on(changeset)[unquote(field)]
      end
    end

    test "employee_uuid is required" do
      params = params_for_command(:request_timeoff)

      assert {:error, changeset} = Absences.request_timeoff(params)

      assert "can't be blank" in errors_on(changeset).employee_uuid
    end

    test "start_date can be equal to end date" do
      date = ~D[2019-04-10]

      params =
        params_for_command(:request_timeoff, start_date: date, end_date: date)
        |> with_employee()

      assert Absences.request_timeoff(params)
    end

    test "start date must be before end date" do
      params =
        params_for_command(:request_timeoff, start_date: ~D[2019-04-10], end_date: ~D[2019-04-09])
        |> with_employee()

      assert {:error, %Ecto.Changeset{} = changeset} = Absences.request_timeoff(params)
      assert "must be after start date" in errors_on(changeset).end_date
    end
  end
end
