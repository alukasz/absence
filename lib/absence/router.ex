defmodule Absence.Router do
  use Absence.Dispatcher

  alias Absence.Absences.Aggregates.Timeoff
  alias Absence.Absences.Commands.AddHours

  dispatch AddHours, to: Timeoff, identity: :timeoff_id
end
