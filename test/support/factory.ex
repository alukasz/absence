defmodule Absence.Factory do
  defdelegate build_aggregate(factory_name, attrs \\ []), to: Absence.Factory.AggregateFactory, as: :build

  defdelegate build_command(factory_name, attrs \\ []), to: Absence.Factory.CommandFactory, as: :build

  defdelegate build_event(factory_name, attrs \\ []), to: Absence.Factory.EventFactory, as: :build
end
