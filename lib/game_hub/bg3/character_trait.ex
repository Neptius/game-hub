defmodule GameHub.Bg3.CharacterTrait do
  use Ecto.Schema

  schema "bg3_character_traits" do
    field :contentuid, :string
    field :name, :string
    field :description, :string

    timestamps(type: :utc_datetime)
  end
end
