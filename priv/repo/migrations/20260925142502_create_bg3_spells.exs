defmodule GameHub.Repo.Migrations.CreateBg3Spells do
  use Ecto.Migration

  def change do
    create table(:bg3_spells) do
      add :internalId, :string, null: false
      add :name, :string, null: false
      add :nameUid, :string, null: false
      add :description, :text, null: false
      add :descriptionUid, :text, null: false
      add :level, :integer, null: false
      add :school, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(
             :bg3_spells,
             [:internalId]
           )
  end
end
