defmodule Absence.Factory.AggregateFactory do
  use ExMachina

  alias Absence.Absences.Aggregates

  def employee_factory do
    %Aggregates.Employee{
      uuid: EventSourcing.UUID.generate(),
      hours: 80
    }
  end
end
