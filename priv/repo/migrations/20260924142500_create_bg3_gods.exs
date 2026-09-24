defmodule GameHub.Repo.Migrations.CreateBg3Gods do
  use Ecto.Migration

  def change do
    create table(:bg3_gods) do
      add :contentuid, :string, null: false
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(
             :bg3_gods,
             [:contentuid]
           )
  end
end
