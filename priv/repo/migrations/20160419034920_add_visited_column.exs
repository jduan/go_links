defmodule GoLinks.Repo.Migrations.AddVisitedColumn do
  use Ecto.Migration

  def change do
    alter table(:links) do
      add :visited, :integer
    end
  end
end
