defmodule AbsenceWeb.TimeoffPolicy do
  import AbsenceWeb.ControllerHelper

  def index(_) do
    true
  end

  def new(user) do
    has_team_leader?(user)
  end

  def create(user) do
    has_team_leader?(user)
  end
end
