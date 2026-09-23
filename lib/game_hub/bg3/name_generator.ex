defmodule GameHub.Bg3.NameGenerator do
  @moduledoc """
  Generates fantasy-style names inspired by Baldur's Gate / Forgotten Realms.
  """

  @races %{
    "Humain" => %{
      first: [
        "Aldric",
        "Caelan",
        "Edrin",
        "Gareth",
        "Mira",
        "Rowan",
        "Talia",
        "Soren",
        "Bran",
        "Lysa"
      ],
      last: [
        "Ashcroft",
        "Briar",
        "Dunwell",
        "Fenwick",
        "Harrow",
        "Larkspur",
        "Redwood",
        "Voss",
        "Vale",
        "Thorne"
      ]
    },
    "Elfe" => %{
      first: [
        "Aelrith",
        "Calandor",
        "Elyr",
        "Lethen",
        "Nimra",
        "Saelira",
        "Sylvaen",
        "Thalion",
        "Vael",
        "Ilyra"
      ],
      last: [
        "Moonshadow",
        "Silverbough",
        "Starweaver",
        "Sunveil",
        "Thistlebrook",
        "Wrenleaf",
        "Eldergleam",
        "Feymere",
        "Dawnsong",
        "Winterlace"
      ]
    },
    "Semi-elfe" => %{
      first: [
        "Arieth",
        "Dalen",
        "Elowen",
        "Myris",
        "Seren",
        "Tavren",
        "Veyra",
        "Ylian",
        "Cairn",
        "Nessa"
      ],
      last: [
        "Moonbloom",
        "Glassmere",
        "Duskfall",
        "Thornvale",
        "Sablewind",
        "Silverveil",
        "Rosefen",
        "Stoneglow",
        "Mosssong",
        "Hearthline"
      ]
    },
    "Nain" => %{
      first: [
        "Borin",
        "Dagna",
        "Garrik",
        "Korrin",
        "Nessa",
        "Orik",
        "Rurik",
        "Thorn",
        "Vala",
        "Yarin"
      ],
      last: [
        "Ironvein",
        "Stoneforge",
        "Graniteclaw",
        "Deeproot",
        "Emberback",
        "Cinderhall",
        "Ashmantle",
        "Torchbane",
        "Waystone",
        "Frostpeak"
      ]
    },
    "Halfelin" => %{
      first: [
        "Bramble",
        "Daisy",
        "Milo",
        "Pip",
        "Rosie",
        "Tobin",
        "Wren",
        "Lark",
        "Nella",
        "Poppy"
      ],
      last: [
        "Berrytop",
        "Mosswick",
        "Oakbloom",
        "Puddlefoot",
        "Needlewick",
        "Sunlark",
        "Cloverbend",
        "Bracken",
        "Hearthmere",
        "Bellwood"
      ]
    },
    "Gnome" => %{
      first: [
        "Bix",
        "Fizz",
        "Nim",
        "Pipkin",
        "Quill",
        "Tink",
        "Vex",
        "Wobble",
        "Zella",
        "Ibb"
      ],
      last: [
        "Copperwhistle",
        "Mossspinner",
        "Lampwick",
        "Gadgetvein",
        "Tumblecog",
        "Cinderfoot",
        "Rookgnome",
        "Hollowgear",
        "Saffroncap",
        "Brassbloom"
      ]
    },
    "Demi-orque" => %{
      first: [
        "Brakka",
        "Druuk",
        "Gorren",
        "Kharra",
        "Morga",
        "Rukk",
        "Sharna",
        "Torg",
        "Ugra",
        "Vekha"
      ],
      last: [
        "Skullbreaker",
        "Redhand",
        "Stonejaw",
        "Ironhorn",
        "Warbrow",
        "Fangmaw",
        "Ashgrave",
        "Bloodspear",
        "Stormcleave",
        "Mireclaw"
      ]
    },
    "Tieffelin" => %{
      first: [
        "Azrith",
        "Daeva",
        "Morthos",
        "Nyris",
        "Ravik",
        "Sable",
        "Sythra",
        "Vharis",
        "Zeth",
        "Nyx"
      ],
      last: [
        "Flamebrand",
        "Voidstep",
        "Ashenmark",
        "Nightveil",
        "Emberwing",
        "Crowbane",
        "Riftstitch",
        "Hollowthorn",
        "Blackglass",
        "Obsidianvein"
      ]
    },
    "Drow" => %{
      first: [
        "Ariane",
        "Dhalia",
        "Elyss",
        "Luriel",
        "Nyra",
        "Sethra",
        "Tavra",
        "Veyla",
        "Zuliel",
        "Nhalia"
      ],
      last: [
        "Nightshade",
        "Moonweft",
        "Velvetspine",
        "Duskmask",
        "Blackdew",
        "Silvershade",
        "Duskglass",
        "Latticeveil",
        "Fangmist",
        "Shadowmere"
      ]
    },
    "Githyanki" => %{
      first: [
        "Kael",
        "Nerith",
        "Qyz",
        "Rhaak",
        "Sivra",
        "Talar",
        "Vhath",
        "Xira",
        "Zaruk",
        "Keth"
      ],
      last: [
        "Starbreaker",
        "Voidrunner",
        "Ironmind",
        "Silverblade",
        "Skyclaw",
        "Crownfeather",
        "Voidmarch",
        "Nightreaver",
        "Lanternspear",
        "Frostwing"
      ]
    }
  }

  @generic %{
    first: [
      "Alyra",
      "Bren",
      "Cyrin",
      "Dorian",
      "Elara",
      "Faelan",
      "Garin",
      "Hera",
      "Ilya",
      "Jorren"
    ],
    last: [
      "Ash",
      "Moon",
      "Stone",
      "Briar",
      "Vale",
      "Hollow",
      "Star",
      "Thorne",
      "Frost",
      "Rook"
    ]
  }

  @doc """
  Generates a fantasy name for the given race.
  Example:
      NameGenerator.generate(\"Elfe\") => \"Aelrith Moonshadow\"
  """
  def generate(race, opts \\ []) do
    normalized = normalize_race(race)

    pool =
      @races
      |> Map.get(normalized, @generic)

    first =
      pool.first
      |> Enum.random()

    last =
      pool.last
      |> Enum.random()

    format = Keyword.get(opts, :format, :full)

    case format do
      :first -> first
      :last -> last
      :full -> "#{first} #{last}"
      _ -> "#{first} #{last}"
    end
  end

  @doc """
  List supported races.
  """
  def supported_races do
    @races
    |> Map.keys()
    |> Enum.sort()
  end

  defp normalize_race(race) when is_binary(race) do
    race = String.trim(race)

    case race do
      "Humain" -> "Humain"
      "Elfe" -> "Elfe"
      "Semi-elfe" -> "Semi-elfe"
      "Nain" -> "Nain"
      "Halfelin" -> "Halfelin"
      "Gnome" -> "Gnome"
      "Demi-orque" -> "Demi-orque"
      "Tieffelin" -> "Tieffelin"
      "Drow" -> "Drow"
      "Githyanki" -> "Githyanki"
      _ -> "generic"
    end
  end

  defp normalize_race(_), do: "generic"
end
