defmodule Absence.Absences.Contract do
  alias Ecto.Changeset
  alias Absence.Absences.TimeoffRequest
  alias Absence.Accounts.User

  @callback get_employee(User.t()) :: Employee.t()
  @callback get_employee_team_leader(User.t()) :: TeamLeader.t() | nil
  @callback get_team_leader(User.t()) :: TeamLeader.t() | nil

  @callback get_timeoff_requests(User.t()) :: [TimeoffRequest.t()]
  @callback get_team_leader_timeoff_requests(User.t()) :: [TimeoffRequest.t()]

  @callback request_timeoff() :: Changeset.t()
  @callback request_timeoff(User.t(), map()) :: :ok | {:error, Changeset.t()}

  @callback approve_timeoff_request() :: Changeset.t()
  @callback approve_timeoff_request(User.t(), map()) :: :ok | {:error, Changeset.t()}

  @callback reject_timeoff_request() :: Changeset.t()
  @callback reject_timeoff_request(User.t(), map()) :: :ok | {:error, Changeset.t()}
end
