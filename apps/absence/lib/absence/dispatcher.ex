defmodule Absence.Dispatcher do
  use EventSourcing.Dispatcher

  alias Absence.Absences.Aggregates.Employee
  alias Absence.Absences.Aggregates.TeamLeader
  alias Absence.Absences.Commands.AddHours
  alias Absence.Absences.Commands.RequestTimeoff
  alias Absence.Absences.Commands.ReviewTimeoffRequest
  alias Absence.Absences.Commands.ApproveTimeoffRequest
  alias Absence.Absences.Commands.RejectTimeoffRequest
  alias Absence.Absences.Commands.SetTeamLeader
  alias Absence.Absences.Commands.MakeTeamLeader

  dispatch AddHours, to: Employee, identity: :employee_uuid
  dispatch RequestTimeoff, to: Employee, identity: :employee_uuid
  dispatch SetTeamLeader, to: Employee, identity: :employee_uuid
  dispatch MakeTeamLeader, to: Employee, identity: :employee_uuid

  dispatch ReviewTimeoffRequest, to: TeamLeader, identity: :team_leader_uuid
  dispatch ApproveTimeoffRequest, to: TeamLeader, identity: :team_leader_uuid
  dispatch RejectTimeoffRequest, to: TeamLeader, identity: :team_leader_uuid
end
