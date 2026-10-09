defmodule GameHub.BG3.SubClasse do
  use Ecto.Schema
  import Ecto.Changeset

  alias GameHub.BG3.Classe

  schema "sub_classes" do
    field :internal_id, :string
    field :name, :string
    field :name_uid, :string
    field :description, :string
    field :description_uid, :string
    field :classe_uid, :string

    belongs_to :classe, Classe

    timestamps()
  end

  @doc false
  def changeset(sub_classe, attrs) do
    sub_classe
    |> cast(attrs, [
      :name,
      :name_uid,
      :description,
      :description_uid,
      :classe_id
    ])
    |> validate_required([
      :name,
      :name_uid,
      :description,
      :description_uid,
      :classe_id
    ])
  end
end
