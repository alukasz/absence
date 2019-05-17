defmodule Absence.Absences do
  @behaviour Absence.Absences.Contract

  alias Absence.Dispatcher
  alias Absence.Absences.Commands
  alias Absence.Absences.Contract
  alias Absence.Absences.Aggregates.Employee

  @impl Contract
  def request_timeoff, do: Commands.RequestTimeoff.changeset()

  @impl Contract
  def request_timeoff(subject, timeoff_params) do
    timeoff_params
    |> put_employee(subject)
    |> Commands.RequestTimeoff.build()
    |> Dispatcher.dispatch()
  end

  defp put_employee(params, %Absence.Accounts.User{employee_uuid: employee_uuid}) do
    Map.put(params, "employee_uuid", employee_uuid)
  end

  defp put_employee(params, %Employee{uuid: employee_uuid}) do
    Map.put(params, "employee_uuid", employee_uuid)
  end

  defp put_employee(params, employee_uuid) when is_binary(employee_uuid) do
    Map.put(params, "employee_uuid", employee_uuid)
  end
end
