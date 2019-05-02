defmodule Absence.Absences.Commands.RequestTimeoff do
  defstruct [
    :uuid,
    :employee_uuid,
    :start_date,
    :end_date
  ]

  # for now manually build/cast changeset used to create Phoenix form
  # TODO extract common functions into EventSourcing.Command
  # or separate "form" layer in AbsenceWeb
  @schema %{
    employee_uuid: Ecto.UUID,
    start_date: :date,
    end_date: :date
  }

  def changeset do
    cast(%{})
  end

  def build(params) do
    params
    |> cast()
    |> validate()
    |> Ecto.Changeset.apply_action(:insert)
    |> case do
      {:ok, changes} -> {:ok, struct(__MODULE__, changes)}
      error -> error
    end
  end

  defp validate(changeset) do
    changeset
    |> Ecto.Changeset.validate_required(Map.keys(@schema))
    |> validate_dates_succession()
  end

  defp validate_dates_succession(%{valid?: false} = changeset), do: changeset

  defp validate_dates_succession(changeset) do
    %{start_date: start_date, end_date: end_date} = changeset.changes

    case Date.compare(start_date, end_date) do
      :gt -> Ecto.Changeset.add_error(changeset, :end_date, "must be after start date")
      _ -> changeset
    end
  end

  defp cast(params) do
    empty_map = Map.keys(@schema) |> Enum.reduce(%{}, fn key, acc -> Map.put(acc, key, nil) end)
    changeset = Ecto.Changeset.cast({%{}, @schema}, params, Map.keys(@schema))
    put_in(changeset.changes, Map.merge(empty_map, changeset.changes))
  end
end
