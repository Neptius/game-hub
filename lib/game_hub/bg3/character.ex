defmodule GameHub.Bg3.Character do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "baldurs_gate_3_characters" do
    field :name, :string
    field :race, :string
    field :subrace, :string
    field :class, :string
    field :subclass, :string
    field :background, :string
    field :alignment, :string
    field :strength, :integer, default: 18
    field :dexterity, :integer, default: 14
    field :constitution, :integer, default: 16
    field :intelligence, :integer, default: 8
    field :wisdom, :integer, default: 10
    field :charisma, :integer, default: 8
    field :notes, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(character, attrs) do
    character
    |> cast(attrs, [
      :name,
      :race,
      :subrace,
      :class,
      :subclass,
      :background,
      :alignment,
      :strength,
      :dexterity,
      :constitution,
      :intelligence,
      :wisdom,
      :charisma,
      :notes
    ])
    |> validate_required([
      :name,
      :race,
      :class,
      :background,
      :strength,
      :dexterity,
      :constitution,
      :intelligence,
      :wisdom,
      :charisma
    ])
    |> validate_length(:name, greater_than_or_equal_to: 2, less_than_or_equal_to: 80)
    |> validate_inclusion(:race, supported_races(), message: "is not a supported race")
    |> validate_inclusion(:class, supported_classes(), message: "is not a supported class")
    |> validate_inclusion(:background, supported_backgrounds(), message: "is not a supported background")
    |> validate_inclusion(:alignment, supported_alignments(), message: "is not a supported alignment")
    |> validate_number(:strength, greater_than_or_equal_to: 3, less_than_or_equal_to: 20)
    |> validate_number(:dexterity, greater_than_or_equal_to: 3, less_than_or_equal_to: 20)
    |> validate_number(:constitution, greater_than_or_equal_to: 3, less_than_or_equal_to: 20)
    |> validate_number(:intelligence, greater_than_or_equal_to: 3, less_than_or_equal_to: 20)
    |> validate_number(:wisdom, greater_than_or_equal_to: 3, less_than_or_equal_to: 20)
    |> validate_number(:charisma, greater_than_or_equal_to: 3, less_than_or_equal_to: 20)
  end

  defp supported_races do
    [
      "Humain",
      "Elfe",
      "Semi-elfe",
      "Nain",
      "Halfelin",
      "Gnome",
      "Demi-orque",
      "Tieffelin",
      "Drow",
      "Githyanki"
    ]
  end

  defp supported_classes do
    [
      "Barbare",
      "Barde",
      "Clerc",
      "Druide",
      "Guerrier",
      "Moine",
      "Paladin",
      "Rôdeur",
      "Roublard",
      "Ensorceleur",
      "Magicien",
      "Occultiste"
    ]
  end

  defp supported_backgrounds do
    [
      "Acolyte",
      "Charlatan",
      "Criminal",
      "Entertainer",
      "Folk Hero",
      "Guild Artisan",
      "Haunted One (Dark Urge)",
      "Noble",
      "Outlander",
      "Sage",
      "Soldier",
      "Urchin"
    ]
  end

  defp supported_alignments do
    [
      "Lawful Good",
      "Neutral Good",
      "Chaotic Good",
      "Lawful Neutral",
      "True Neutral",
      "Chaotic Neutral",
      "Lawful Evil",
      "Neutral Evil",
      "Chaotic Evil"
    ]
  end
end
