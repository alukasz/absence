defmodule Absence.Factory.AggregateFactory do
  use ExMachina

  alias Absence.Absences.Aggregates

  def employee_factory do
    %Aggregates.Employee{
      uuid: EventSourcing.UUID.generate(),
      hours: 80
    }
  end

  def team_leader_factory do
    %Aggregates.TeamLeader{
      uuid: :rand.uniform(10000),
      employee_uuid: :rand.uniform(10000)
    }
  end
end
