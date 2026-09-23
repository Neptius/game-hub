defmodule GameHub.Repo.Migrations.CreateBaldursGate3Characters do
  use Ecto.Migration

  def change do
    create table(:baldurs_gate_3_characters, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :race, :string, null: false
      add :subrace, :string
      add :class, :string, null: false
      add :subclass, :string
      add :background, :string, null: false
      add :alignment, :string
      add :strength, :integer, null: false
      add :dexterity, :integer, null: false
      add :constitution, :integer, null: false
      add :intelligence, :integer, null: false
      add :wisdom, :integer, null: false
      add :charisma, :integer, null: false
      add :notes, :text

      timestamps(type: :utc_datetime)
    end
  end
end
