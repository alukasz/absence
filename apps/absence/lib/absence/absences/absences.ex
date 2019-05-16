defmodule Absence.Absences do
  @behaviour Absence.Absences.Contract

  alias Absence.Dispatcher
  alias Absence.Absences.Commands
  alias Absence.Absences.Contract

  @impl Contract
  def request_timeoff, do: Commands.RequestTimeoff.changeset()

  @impl Contract
  def request_timeoff(employee, timeoff_params) do
    timeoff_params
    |> put_employee(employee)
    |> Commands.RequestTimeoff.build()
    |> Dispatcher.dispatch()
  end

  defp put_employee(params, employee_uuid) when is_binary(employee_uuid) do
    Map.put(params, "employee_uuid", employee_uuid)
  end
end
