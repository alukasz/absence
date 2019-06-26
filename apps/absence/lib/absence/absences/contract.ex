defmodule Absence.Absences.Contract do
  alias Ecto.Changeset
  alias EventSourcing.UUID
  alias Absence.Absences.TimeoffRequest
  alias Absence.Accounts.User

  @type subject :: UUID.t() | User.t() | Employee.t()

  @callback get_employee(User.t()) :: Employee.t()

  @callback get_employee_team_leader(Employee.t()) :: TeamLeader.t()

  @callback get_team_leader(User.t() | Employee.t()) :: TeamLeader.t() | nil

  @callback get_timeoff_requests(subject()) :: [TimeoffRequest.t()]

  @callback request_timeoff() :: Changeset.t()

  @callback request_timeoff(subject(), map()) :: :ok | {:error, Changeset.t()}
end
