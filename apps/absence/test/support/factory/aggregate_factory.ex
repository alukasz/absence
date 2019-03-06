defmodule Absence.Factory.AggregateFactory do
  use ExMachina

  alias Absence.Absences.Aggregates

  def employee_factory do
    %Aggregates.Employee{
      uuid: :rand.uniform(10000),
      hours: 80
    }
  end
end