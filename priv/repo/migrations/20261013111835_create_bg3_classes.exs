defmodule GameHub.Repo.Migrations.CreateBg3Classes do
  use Ecto.Migration

  def change do
    create table(:bg3_classes) do
      add :internal_id, :string, null: false
      add :name, :string
      add :name_uid, :string
      add :description, :text
      add :description_uid, :string
      add :base_hp, :integer
      add :hp_per_level, :integer
      add :spell_list_uid, :string
      add :primary_ability, :string
      add :spell_casting_ability, :string

      timestamps()
    end

    create unique_index(:bg3_classes, [:internal_id])


    create table(:bg3_sub_classes) do
      add :internal_id, :string, null: false
      add :name, :string
      add :name_uid, :string
      add :description, :text
      add :description_uid, :string
      add :role, :string
      add :classe_uid, :string
      add :classe_id,
        references(:bg3_classes, on_delete: :delete_all),
        null: false

      timestamps()
    end

    create unique_index(:bg3_sub_classes, [:internal_id])
  end
end
