defmodule Absence.Absences do
  alias Absence.Dispatcher
  alias Absence.Absences.Commands

  def request_timeoff, do: Commands.RequestTimeoff.changeset()

  def request_timeoff(employee_uuid, timeoff_params) do
    timeoff_params
    |> put_employee(employee_uuid)
    |> Commands.RequestTimeoff.build()
    |> Dispatcher.dispatch()
  end

  defp put_employee(params, employee_uuid) do
    Map.put(params, "employee_uuid", employee_uuid)
  end
end
