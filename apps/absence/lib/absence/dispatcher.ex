defmodule Absence.Dispatcher do
  use EventSourcing.Dispatcher

  alias Absence.Absences.Aggregates.Employee
  alias Absence.Absences.Commands.AddHours
  alias Absence.Absences.Commands.RequestTimeoff

  dispatch AddHours, to: Employee, identity: :employee_uuid
  dispatch RequestTimeoff, to: Employee, identity: :employee_uuid
end
