defmodule GameHub.BG3.Importer.ClasseImporter do
  import Ecto.Query
  import SweetXml

  alias GameHub.Repo

  alias GameHub.BG3.Classe
  alias GameHub.BG3.SubClasse


  @lsx_paths [
    "/Users/aymeric/Documents/Dev/Perso/game_hub/uploads/BG3/Mods/HomeBrew-extracted/Public/HomeBrew - Comprehensive Reworks/ClassDescriptions/ClassDescriptions.lsx"
  ]

  @xml_paths [
    "/Users/aymeric/Documents/Dev/Perso/game_hub/uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Classes Reworked (Artificer).xml",
    "/Users/aymeric/Documents/Dev/Perso/game_hub/uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Classes Reworked (Barbarian).xml",
    "/Users/aymeric/Documents/Dev/Perso/game_hub/uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Classes Reworked (Bard).xml",
    "/Users/aymeric/Documents/Dev/Perso/game_hub/uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Classes Reworked (Cleric).xml",
    "/Users/aymeric/Documents/Dev/Perso/game_hub/uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Classes Reworked (Druid).xml",
    "/Users/aymeric/Documents/Dev/Perso/game_hub/uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Classes Reworked (Fighter).xml",
    "/Users/aymeric/Documents/Dev/Perso/game_hub/uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Classes Reworked (Monk).xml",
    "/Users/aymeric/Documents/Dev/Perso/game_hub/uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Classes Reworked (Paladin).xml",
    "/Users/aymeric/Documents/Dev/Perso/game_hub/uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Classes Reworked (Ranger).xml",
    "/Users/aymeric/Documents/Dev/Perso/game_hub/uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Classes Reworked (Rogue).xml",
    "/Users/aymeric/Documents/Dev/Perso/game_hub/uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Classes Reworked (Sorcerer).xml",
    "/Users/aymeric/Documents/Dev/Perso/game_hub/uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Classes Reworked (Warlock).xml",
    "/Users/aymeric/Documents/Dev/Perso/game_hub/uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Classes Reworked (Wizard).xml"
  ]

  def import do
    # Repo.transaction(fn ->
    localizations = load_localizations()

    rows =
      @lsx_paths
      |> Enum.flat_map(&parse_file!/1)
      |> Enum.map(&build_class/1)
      |> Enum.map(&create_record(&1, localizations))

    # end)
  end

  # ---------------------------------------------------------------------------
  # LSX parsing
  # ---------------------------------------------------------------------------

  defp parse_file!(path) do
    path
    |> File.read!()
    |> SweetXml.parse()
    |> xpath(
      ~x"//region[@id='ClassDescriptions']/node[@id='root']/children/node[@id='ClassDescription']"l,
      attributes: [
        ~x"./attribute"l,
        id: ~x"./@id"s,
        type: ~x"./@type"s,
        value: ~x"./@value"s,
        handle: ~x"./@handle"s
      ]
    )
  end

  defp build_class(%{attributes: attrs}) do
    attrs
    |> Map.new(fn a -> {a.id, cast(a)} end)
  end

  defp cast(%{type: "int32", value: v}), do: String.to_integer(v)
  defp cast(%{type: "uint8", value: v}), do: String.to_integer(v)
  defp cast(%{type: "bool", value: v}), do: v == "true"

  defp cast(%{type: "TranslatedString"} = a), do: a.handle

  defp cast(%{type: "LSString", value: v}), do: String.split(v, ";")
  defp cast(%{value: v}), do: v

  # ---------------------------------------------------------------------------
  # Localization
  # ---------------------------------------------------------------------------

  defp load_localizations do
    @xml_paths
    |> Enum.flat_map(&parse_localization_file/1)
    |> Map.new()
  end

  defp parse_localization_file(path) do
    path
    |> File.read!()
    |> xpath(
      ~x"//content"l,
      uid: ~x"./@contentuid"s,
      text: ~x"./text()"s
    )
    |> Enum.map(fn localization ->
      {
        localization.uid,
        localization.text
      }
    end)
  end

  defp resolve_localization(nil, _localizations), do: nil

  defp resolve_localization(uid, localizations) do
    Map.get(localizations, uid, uid)
  end

  # ---------------------------------------------------------------------------
  # Entity creation
  # ---------------------------------------------------------------------------

  defp create_record(%{"ParentGuid" => _} = raw, localizations) do
    %SubClasse{
      internal_id: raw["Name"],
      name: resolve_localization(raw["DisplayName"], localizations),
      name_uid: raw["DisplayName"],
      description: resolve_localization(raw["Description"], localizations),
      description_uid: raw["Description"],
      classe_uid: raw["ParentGuid"]
    }
  end


  defp create_record(raw, localizations) do
    %Classe{
      internal_id: raw["Name"],
      name: resolve_localization(raw["DisplayName"], localizations),
      name_uid: raw["DisplayName"],
      description: resolve_localization(raw["Description"], localizations),
      description_uid: raw["Description"],
      base_hp: raw["BaseHp"],
      hp_per_level: raw["HpPerLevel"]
   }
  end



  defp upsert_records(rows) do
  end

  defp delete_removed_records(rows) do
  end
end
