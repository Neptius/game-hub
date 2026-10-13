defmodule GameHub.BG3.Classe do
  use Ecto.Schema
  import Ecto.Changeset

  alias GameHub.BG3.SubClasse

  schema "bg3_classes" do
    field :internal_id, :string
    field :name, :string
    field :name_uid, :string
    field :description, :string
    field :description_uid, :string

    field :base_hp, :integer
    field :hp_per_level, :integer
    field :spell_list_uid, :string
    field :primary_ability, :string
    field :spell_casting_ability, :string

    has_many :sub_classes, SubClasse

    timestamps()
  end

  @doc false
  def changeset(classe, attrs) do
    classe
    |> cast(attrs, [
      :internal_id,
      :name,
      :name_uid,
      :description,
      :description_uid,
      :base_hp,
      :hp_per_level,
      :spell_list_uid,
      :primary_ability,
      :spell_casting_ability
    ])
    |> validate_required([
      :internal_id,
      :name,
      :name_uid,
      :description,
      :description_uid,
      :base_hp,
      :hp_per_level,
      :spell_list_uid,
      :primary_ability,
      :spell_casting_ability
    ])
  end
end
