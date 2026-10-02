defmodule GameHub.Repo.Migrations.CreateBg3Spells do
  use Ecto.Migration

  def change do
    create table(:bg3_spells) do
      add :contentuid, :string, null: false
      add :name, :string, null: false
      add :description, :text, null: false
      add :level, :integer, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(
             :bg3_spells,
             [:contentuid]
           )
  end
end
