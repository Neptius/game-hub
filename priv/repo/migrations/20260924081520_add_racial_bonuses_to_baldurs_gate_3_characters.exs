defmodule GameHub.Repo.Migrations.AddRacialBonusesToBaldursGate3Characters do
  use Ecto.Migration

  def change do
    alter table(:baldurs_gate_3_characters) do
      add :bonus_primary, :string
      add :bonus_secondary, :string
    end
  end
end
