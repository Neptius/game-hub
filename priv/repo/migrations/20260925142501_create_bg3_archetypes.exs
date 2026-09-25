defmodule GameHub.Repo.Migrations.CreateBg3Archetypes do
  use Ecto.Migration

  def change do
    create table(:bg3_archetypes) do
      add :contentuid, :string, null: false
      add :name, :string, null: false
      add :description, :text, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(
             :bg3_archetypes,
             [:contentuid]
           )
  end
end
