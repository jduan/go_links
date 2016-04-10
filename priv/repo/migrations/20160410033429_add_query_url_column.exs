defmodule GoLinks.Repo.Migrations.AddQueryUrlColumn do
  use Ecto.Migration

  def change do
    alter table(:links) do
      add :query_url, :string
    end
  end
end
