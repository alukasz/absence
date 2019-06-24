defmodule Absence.Absences.TimeoffRequest do
  alias __MODULE__
  alias Absence.Absences.Commands.RequestTimeoff

  @uuid_generator Application.get_env(:event_sourcing, :uuid_generator)

  @type t :: struct()

  @derive Jason.Encoder

  defstruct [
    :uuid,
    :employee_uuid,
    :start_date,
    :end_date,
    :status
  ]

  def from_command(%RequestTimeoff{} = command, status \\ :pending) do
    TimeoffRequest
    |> struct(Map.from_struct(command))
    |> Map.put(:uuid, @uuid_generator.generate())
    |> Map.put(:status, status)
  end
end
