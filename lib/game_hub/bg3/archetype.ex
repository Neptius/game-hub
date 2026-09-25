defmodule GameHub.Bg3.Archetype do
  use Ecto.Schema

  schema "bg3_archetypes" do
    field :contentuid, :string
    field :name, :string
    field :description, :string

    timestamps(type: :utc_datetime)
  end
end
