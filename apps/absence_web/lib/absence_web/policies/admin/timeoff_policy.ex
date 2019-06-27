defmodule AbsenceWeb.Admin.TimeoffPolicy do
  import AbsenceWeb.ControllerHelper

  def index(user) do
    team_leader?(user)
  end

  def update(user) do
    team_leader?(user)
  end
end
