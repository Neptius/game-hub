defmodule GameHub.Games do
  @moduledoc """
  Catalog of the games supported by the hub.

  Each game has its own identity (colors, tagline) and a list of features.
  Adding a game = adding an entry here + a `<Game>Live` namespace + routes under `/<slug>`.
  """

  defmodule Feature do
    @moduledoc false
    @enforce_keys [:id, :name, :description, :icon]
    defstruct [:id, :name, :description, :icon, :path]
  end

  defmodule Game do
    @moduledoc false
    @enforce_keys [:slug, :name, :tagline, :accent, :accent_alt]
    defstruct [:slug, :name, :short_name, :tagline, :accent, :accent_alt, :icon, features: []]
  end

  alias __MODULE__.{Feature, Game}

  def list do
    [
      %Game{
        slug: "bg3",
        name: "Baldur's Gate 3",
        short_name: "BG3",
        tagline: "Forgez vos builds, planifiez votre groupe, dominez Faerûn.",
        accent: "#d9a441",
        accent_alt: "#8b1e2d",
        icon: "lucide:dices",
        features: [
          %Feature{
            id: :characters,
            name: "Character Builder",
            description: "Créez et sauvegardez vos builds niveau par niveau.",
            icon: "lucide:sword",
            path: "/bg3/characters"
          },
          %Feature{
            id: :party,
            name: "Party Planner",
            description: "Composez un groupe équilibré de 4 aventuriers.",
            icon: "lucide:users",
            path: nil
          },
          %Feature{
            id: :spells,
            name: "Grimoire",
            description: "Explorez les sorts et leurs effets.",
            icon: "lucide:book-open",
            path: nil
          }
        ]
      },
      %Game{
        slug: "dota2",
        name: "Dota 2",
        short_name: "Dota 2",
        tagline: "Draft, items et stats pour gagner votre prochaine partie.",
        accent: "#e0473a",
        accent_alt: "#2f4f6f",
        icon: "lucide:swords",
        features: [
          %Feature{
            id: :heroes,
            name: "Hero Explorer",
            description: "Fiches et statistiques des héros.",
            icon: "lucide:shield",
            path: nil
          },
          %Feature{
            id: :builds,
            name: "Item Builds",
            description: "Préparez vos ordres d'achat.",
            icon: "lucide:backpack",
            path: nil
          }
        ]
      }
    ]
  end

  def get(slug), do: Enum.find(list(), &(&1.slug == slug))

  def get!(slug), do: get(slug) || raise(ArgumentError, "unknown game #{inspect(slug)}")

  def available?(%Game{features: features}), do: Enum.any?(features, & &1.path)
end
