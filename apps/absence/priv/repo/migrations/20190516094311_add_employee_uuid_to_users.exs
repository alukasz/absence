defmodule Absence.Repo.Migrations.AddEmployeeUuidToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :employee_uuid, :binary_id
    end
  end
end
