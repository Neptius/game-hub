defmodule GameHub.BG3.Classe do
  use Ecto.Schema
  import Ecto.Changeset

  alias GameHub.BG3.SubClasse

  schema "classes" do
    field :internal_id, :string
    field :name, :string
    field :name_uid, :string
    field :description, :string
    field :description_uid, :string

    field :base_hp, :integer
    field :hp_per_level, :integer

    field :force, :integer
    field :dexterity, :integer
    field :constitution, :integer
    field :intelligence, :integer
    field :wisdom, :integer
    field :charisma, :integer

    has_many :sub_classes, SubClasse

    timestamps()
  end

  @doc false
  def changeset(classe, attrs) do
    classe
    |> cast(attrs, [
      :name,
      :description,
      :force,
      :dexterity,
      :constitution,
      :intelligence,
      :wisdom,
      :charisma
    ])
    |> validate_required([
      :name,
      :description,
      :force,
      :dexterity,
      :constitution,
      :intelligence,
      :wisdom,
      :charisma
    ])
  end
end
