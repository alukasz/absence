defmodule Absence.Dispatcher do
  use EventSourcing.Dispatcher

  alias Absence.Absences.Aggregates.Employee
  alias Absence.Absences.Aggregates.TeamLeader
  alias Absence.Absences.Commands.AddHours
  alias Absence.Absences.Commands.RequestTimeoff
  alias Absence.Absences.Commands.ReviewTimeoffRequest

  dispatch AddHours, to: Employee, identity: :employee_uuid
  dispatch RequestTimeoff, to: Employee, identity: :employee_uuid

  dispatch ReviewTimeoffRequest, to: TeamLeader, identity: :team_leader_uuid
end
