defmodule AbsenceWeb.ControllerHelper do
  alias Absence.Accounts.User
  alias Absence.Absences.Aggregates.TeamLeader

  @absences Application.get_env(:absence_web, :absences)

  def current_user(%Plug.Conn{} = conn) do
    conn.assigns.current_user
  end

  def employee(%User{} = user) do
    @absences.get_employee(user)
  end

  def employee_team_leader(%User{} = user) do
    @absences.get_employee_team_leader(user)
  end

  def has_team_leader?(%User{} = user) do
    match?(%TeamLeader{}, employee_team_leader(user))
  end

  def team_leader(%User{} = user) do
    @absences.get_team_leader(user)
  end

  def team_leader?(%User{} = user) do
    team_leader(user) != nil
  end
end
