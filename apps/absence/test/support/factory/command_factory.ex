defmodule Absence.Factory.CommandFactory do
  use ExMachina

  alias Absence.Absences.Commands

  def params_for(factory, attrs \\ %{}) do
    factory
    |> build(attrs)
    |> Map.from_struct()
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

  def request_timeoff_factory do
    %Commands.RequestTimeoff{
      start_date: ~D[2019-01-01],
      end_date: ~D[2019-01-10]
    }
  end

  def approve_timeoff_request_factory do
    %Commands.ApproveTimeoffRequest{}
  end

  def reject_timeoff_request_factory do
    %Commands.RejectTimeoffRequest{}
  end
end
