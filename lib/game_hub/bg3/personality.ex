defmodule GameHub.Bg3.Personality do
  use Ecto.Schema

  schema "bg3_personalities" do
    field :contentuid, :string
    field :name, :string
    field :description, :string

    timestamps(type: :utc_datetime)
  end
end
