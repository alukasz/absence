defmodule Absence.Factory.CommandFactory do
  use ExMachina

  alias Absence.Absences.Commands

  def params_for(factory, attrs \\ %{}) do
    factory
    |> build(attrs)
    |> Map.from_struct()
  end

  def string_params_for(factory, attrs \\ %{}) do
    factory
    |> params_for(attrs)
    |> Map.new(fn {k, v} -> {Atom.to_string(k), v} end)
  end

  def add_hours_factory do
    %Commands.AddHours{
      hours: 8
    }
  end

  def remove_hours_factory do
    %Commands.RemoveHours{
      hours: 8
    }
  end

  def set_team_leader_factory do
    %Commands.SetTeamLeader{}
  end

  def request_timeoff_factory do
    %Commands.RequestTimeoff{
      start_date: ~D[2019-01-01],
      end_date: ~D[2019-01-10]
    }
  end

  def review_timeoff_request_factory do
    %Commands.ReviewTimeoffRequest{}
  end

  def approve_timeoff_request_factory do
    %Commands.ApproveTimeoffRequest{}
  end

  def reject_timeoff_request_factory do
    %Commands.RejectTimeoffRequest{}
  end
end
