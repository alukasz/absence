defmodule Absence.Absences do
  @behaviour Absence.Absences.Contract

  alias Absence.Absences.Commands
  alias Absence.Absences.Contract
  alias Absence.Absences.Employees
  alias Absence.Absences.TeamLeaders
  alias Absence.Dispatcher

  @impl Contract
  defdelegate get_employee(user), to: Employees, as: :get

  @impl Contract
  defdelegate get_employee_team_leader(user), to: Employees, as: :get_team_leader

  @impl Contract
  defdelegate get_team_leader(user), to: TeamLeaders, as: :get

  @impl Contract
  def get_timeoff_requests(user) do
    user
    |> Employees.get_timeoff_requests()
    |> sort_timeoff_requests()
  end

  @impl Contract
  def get_team_leader_timeoff_requests(user) do
    user
    |> TeamLeaders.get_timeoff_requests()
    |> sort_timeoff_requests()
  end

  defp sort_timeoff_requests(requests) do
    requests
    |> Enum.sort_by(&{&1.start_date.year, &1.start_date.month, &1.start_date.day})
    |> Enum.reverse()
  end

  @impl Contract
  def request_timeoff, do: Commands.RequestTimeoff.changeset()

  @impl Contract
  def request_timeoff(user, timeoff_params) do
    timeoff_params
    |> put_employee(user)
    |> Commands.RequestTimeoff.build()
    |> Dispatcher.dispatch()
  end

  defp put_employee(params, %Absence.Accounts.User{employee_uuid: uuid}) do
    Map.put(params, "employee_uuid", uuid)
  end
end
