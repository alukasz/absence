defmodule Absence.Absences.Commands.RequestTimeoff do
  use EventSourcing.Command

  alias Absence.Absences

  command do
    field :employee_uuid, EventSourcing.UUID
    field :start_date, :date
    field :end_date, :date
  end

  defp validate(changeset) do
    changeset
    |> validate_dates_succession()
    |> validate_team_leader()
  end

  defp validate_dates_succession(%{valid?: false} = changeset), do: changeset

  defp validate_dates_succession(changeset) do
    %{start_date: start_date, end_date: end_date} = changeset.changes

    case Date.compare(start_date, end_date) do
      :gt -> Ecto.Changeset.add_error(changeset, :end_date, "must be after start date")
      _ -> changeset
    end
  end

  defp validate_team_leader(%{valid?: false} = changeset), do: changeset

  defp validate_team_leader(changeset) do
    changeset
    |> get_change(:employee_uuid)
    |> Absences.Employees.get()
    |> Absences.Employees.get_team_leader()
    |> case do
      nil -> add_error(changeset, :employee_uuid, "You don't have assigned team leader")
      _ -> changeset
    end
  end
end
