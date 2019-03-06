defmodule Absence.Dispatcher do
  use EventSourcing.Dispatcher

  alias Absence.Absences.Aggregates.Employee
  alias Absence.Absences.Commands.AddHours

  dispatch AddHours, to: Employee, identity: :employee_uuid
end
