defmodule GameHub.Repo.Migrations.CreateBg3Personalities do
  use Ecto.Migration

  def change do
    create table(:bg3_personalities) do
      add :contentuid, :string, null: false
      add :name, :string, null: false
      add :description, :text, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(
             :bg3_personalities,
             [:contentuid]
           )
  end
end
