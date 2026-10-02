defmodule GameHub.Bg3.Spell do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bg3_spells" do
    field :contentuid, :string
    field :name, :string
    field :description, :string
    field :level, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(spell, attrs) do
    spell
    |> cast(attrs, [:contentuid, :name, :description, :level])
    |> validate_required([:contentuid, :name, :description, :level])
  end
end
