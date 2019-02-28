defmodule Absence.Factory.AggregateFactory do
  use ExMachina

  alias Absence.Absences.Aggregates

  def timeoff_factory do
    %Aggregates.Timeoff{
      uuid: :rand.uniform(10000),
      hours: 80
    }
  end
end
