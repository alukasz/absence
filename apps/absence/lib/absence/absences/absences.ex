defmodule Absence.Absences do
  @behaviour Absence.Absences.Contract

  alias Absence.Dispatcher
  alias Absence.Absences.Commands
  alias Absence.Absences.Contract
  alias Absence.Absences.Aggregates.Employee
  alias EventSourcing.Aggregate

  @timeoff_requests_keys [
    :pending_timeoff_requests,
    :approved_timeoff_requests,
    :rejected_timeoff_requests
  ]

  @impl Contract
  def get_timeoff_requests(subject) do
    subject
    |> get_employee()
    |> Map.take(@timeoff_requests_keys)
    |> Map.values()
    |> List.flatten()
    |> Enum.sort_by(&{&1.start_date.year, &1.start_date.month, &1.start_date.day})
    |> Enum.reverse()
  end

  @impl Contract
  def request_timeoff, do: Commands.RequestTimeoff.changeset()

  @impl Contract
  def request_timeoff(subject, timeoff_params) do
    timeoff_params
    |> put_employee(subject)
    |> Commands.RequestTimeoff.build()
    |> Dispatcher.dispatch()
  end

  defp get_employee(%Absence.Accounts.User{employee_uuid: employee_uuid}) do
    Aggregate.get({Employee, employee_uuid})
  end

  defp get_employee(employee_uuid) when is_binary(employee_uuid) do
    Aggregate.get({Employee, employee_uuid})
  end

  defp get_employee(%Employee{uuid: employee_uuid}) do
    Aggregate.get({Employee, employee_uuid})
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
