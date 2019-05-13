defmodule Absence.Absences.Commands.RequestTimeoff do
  use EventSourcing.Command

  command do
    field :employee_uuid, EventSourcing.UUID
    field :start_date, :date
    field :end_date, :date
  end

  defp validate(changeset) do
    validate_dates_succession(changeset)
  end

  defp validate_dates_succession(%{valid?: false} = changeset), do: changeset

  defp validate_dates_succession(changeset) do
    %{start_date: start_date, end_date: end_date} = changeset.changes

    case Date.compare(start_date, end_date) do
      :gt -> Ecto.Changeset.add_error(changeset, :end_date, "must be after start date")
      _ -> changeset
    end
  end
end
