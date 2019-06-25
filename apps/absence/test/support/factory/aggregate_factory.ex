defmodule Absence.Factory.AggregateFactory do
  use ExMachina

  alias Absence.Absences.Aggregates

  def employee_factory do
    %Aggregates.Employee{
      uuid: EventSourcing.UUID.generate(),
      hours: 80,
      team_leader_uuid: EventSourcing.UUID.generate()
    }
  end

  def team_leader_factory do
    %Aggregates.TeamLeader{
      uuid: EventSourcing.UUID.generate(),
      employee_uuid: EventSourcing.UUID.generate()
    }
  end
end
