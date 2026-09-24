defmodule GameHub.Bg3.God do
  use Ecto.Schema

  schema "bg3_gods" do
    field :contentuid, :string
    field :name, :string

    timestamps(type: :utc_datetime)
  end
end
