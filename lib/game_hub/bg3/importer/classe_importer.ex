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
    Repo.transaction(fn ->
      localizations = load_localizations()

      {classe_records, sub_classes_records} =
        @lsx_paths
        |> Enum.flat_map(&parse_file!/1)
        |> Enum.map(&build_class/1)
        |> Enum.map(&create_record(&1, localizations))
        |> organize_records()

      upsert_classe_records(classe_records)
      upsert_sub_classe_records(sub_classes_records)
    end)
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
    %{
      internal_id: raw["UUID"],
      name: resolve_localization(raw["DisplayName"], localizations),
      name_uid: raw["DisplayName"],
      description: parse_description(raw["Description"], localizations),
      description_uid: raw["Description"],
      role: parse_role(raw["Description"], localizations),
      classe_uid: raw["ParentGuid"]
    }
  end

  defp create_record(raw, localizations) do
    %{
      internal_id: raw["UUID"],
      name: resolve_localization(raw["DisplayName"], localizations),
      name_uid: raw["DisplayName"],
      description: parse_description(raw["Description"], localizations),
      description_uid: raw["Description"],
      base_hp: raw["BaseHp"],
      hp_per_level: raw["HpPerLevel"],
      spell_list_uid: raw["SpellList"],
      primary_ability: map_ability(raw["PrimaryAbility"]),
      spell_casting_ability: map_ability(raw["SpellCastingAbility"])
    }
  end

  defp organize_records(rows) do
    Enum.split_with(rows, fn
      %{classe_uid: _} -> false
      _ -> true
    end)
  end

  defp upsert_classe_records([]), do: {0, nil}

  defp upsert_classe_records(classe_records) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    classe_records =
      Enum.map(classe_records, fn classe ->
        classe
        |> Map.put(:inserted_at, now)
        |> Map.put(:updated_at, now)
      end)

    Repo.insert_all(Classe, classe_records,
      on_conflict: {:replace_all_except, [:id, :inserted_at]},
      conflict_target: [:internal_id]
    )
  end

  defp upsert_sub_classe_records([]), do: {0, nil}

  defp upsert_sub_classe_records(sub_classe_records) do
    classes = Repo.all(Classe)

    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    sub_classe_records =
      Enum.map(sub_classe_records, fn sub_classe ->
        sub_classe
        |> Map.put(:inserted_at, now)
        |> Map.put(:updated_at, now)
        |> Map.put(
          :classe_id,
          classes |> Enum.find(fn c -> c.internal_id == sub_classe.classe_uid end) |> Map.get(:id)
        )
      end)

    Repo.insert_all(SubClasse, sub_classe_records,
      on_conflict: {:replace_all_except, [:id, :inserted_at]},
      conflict_target: [:internal_id]
    )
  end

  defp delete_removed_records(rows) do
  end

  # ---------------------------------------------------------------------------
  # Helper functions
  # ---------------------------------------------------------------------------

  # Parses a raw description string, resolves its localization and remove the role information.
  defp parse_description(description_uid, localizations) do
    description_uid
    |> resolve_localization(localizations)
    |> String.replace(~r/Intended Role\(s\): .+/, "")
  end

  # Parses a description string and returns the intended role(s), or nil.
  defp parse_role(description_uid, localizations) do
    raw_description = resolve_localization(description_uid, localizations)

    case Regex.run(~r/Intended Role\(s\): (.+)/, raw_description) do
      [_, role] -> role
      _ -> "N/A"
    end
  end

  # Maps abilities from the raw data.
  defp map_ability(raw_ability) do
    case raw_ability do
      1 -> "Strength"
      2 -> "Dexterity"
      3 -> "Constitution"
      4 -> "Intelligence"
      5 -> "Wisdom"
      6 -> "Charisma"
      _ -> "Unknown"
    end
  end
end
