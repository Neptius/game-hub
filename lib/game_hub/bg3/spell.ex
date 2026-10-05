defmodule GameHub.Bg3.Spell do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bg3_spells" do
    field :internalId, :string
    field :name, :string
    field :description, :string
    field :level, :integer
    field :school, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(spell, attrs) do
    spell
    |> cast(attrs, [:internalId, :name, :description, :level, :school])
    |> validate_required([:internalId, :name, :description, :level, :school])
  end
end
