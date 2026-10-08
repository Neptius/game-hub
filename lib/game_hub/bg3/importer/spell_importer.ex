defmodule GameHub.Bg3.Importer.SpellImporter do
  alias GameHub.Bg3.Spell
  alias GameHub.Repo

  import Ecto.Query
  import SweetXml

  @txt_paths [
    "./uploads/BG3/Mods/HomeBrew-extracted/Public/HomeBrew - Comprehensive Reworks/Stats/Generated/Data/Spells Reworked - Spell_Projectile.txt",
    "./uploads/BG3/Mods/HomeBrew-extracted/Public/HomeBrew - Comprehensive Reworks/Stats/Generated/Data/Spells Reworked - Spell_Rush.txt",
    "./uploads/BG3/Mods/HomeBrew-extracted/Public/HomeBrew - Comprehensive Reworks/Stats/Generated/Data/Spells Reworked - Spell_Shout.txt",
    "./uploads/BG3/Mods/HomeBrew-extracted/Public/HomeBrew - Comprehensive Reworks/Stats/Generated/Data/Spells Reworked - Spell_Target.txt",
    "./uploads/BG3/Mods/HomeBrew-extracted/Public/HomeBrew - Comprehensive Reworks/Stats/Generated/Data/Spells Reworked - Spell_Teleportation.txt",
    "./uploads/BG3/Mods/HomeBrew-extracted/Public/HomeBrew - Comprehensive Reworks/Stats/Generated/Data/Spells Reworked - Spell_Throw.txt",
    "./uploads/BG3/Mods/HomeBrew-extracted/Public/HomeBrew - Comprehensive Reworks/Stats/Generated/Data/Spells Reworked - Spell_Wall.txt",
    "./uploads/BG3/Mods/HomeBrew-extracted/Public/HomeBrew - Comprehensive Reworks/Stats/Generated/Data/Spells Reworked - Spell_Zone.txt"
  ]

  @xml_paths [
    "./uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Spells Reworked.xml",
    "./uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Spells Reworked - 5e Integration.xml",
    "./uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Spells Reworked - Dawnstar Integration.xml"
  ]

  def import do
    Repo.transaction(fn ->
      localizations = load_localizations()

      rows =
        @txt_paths
        |> Enum.flat_map(&parse_file/1)
        |> Enum.map(&create_record(&1, localizations))

      upsert_records(rows)
      delete_removed_records(rows)

      :ok
    end)
  end

  # ---------------------------------------------------------------------------
  # TXT parsing
  # ---------------------------------------------------------------------------

  defp parse_file(path) do
    path
    |> File.read!()
    |> String.split(~r/\R/)
    |> Enum.reduce([], &parse_line/2)
    |> Enum.reverse()
    |> Enum.filter(&spell?/1)
  end

  defp spell?(%{data: data}) do
    (data["Level"] == "0" or data["Level"] == "1") and
      data["DisplayName"] != nil and
      data["Description"] != nil and
      data["SpellSchool"] != nil
  end

  defp spell?(_), do: false

  defp parse_line(line, []) do
    line = String.trim(line)

    case Regex.run(~r/^new entry "([^"]+)"/, line) do
      [_, id] ->
        [%{id: id, data: %{}}]

      _ ->
        []
    end
  end

  defp parse_line(line, [current | rest]) do
    line = String.trim(line)

    cond do
      Regex.match?(~r/^new entry "/, line) ->
        case Regex.run(
               ~r/^new entry "([^"]+)"/,
               line,
               capture: :all_but_first
             ) do
          [id] ->
            [%{id: id, data: %{}} | [current | rest]]

          _ ->
            [current | rest]
        end

      Regex.match?(~r/^data "/, line) ->
        case Regex.run(
               ~r/^data "([^"]+)" "(.*)"$/,
               line,
               capture: :all_but_first
             ) do
          [key, value] ->
            data = Map.put(current.data, key, value)

            [%{current | data: data} | rest]

          _ ->
            [current | rest]
        end

      true ->
        [current | rest]
    end
  end

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

  # Garde uniquement la partie avant le premier ";"
  #
  # Exemple :
  # "hceb123456;1" -> "hceb123456"
  # "hceb123456;4" -> "hceb123456"
  defp uid(value) when is_binary(value) do
    value
    |> String.split(";", parts: 2)
    |> hd()
  end

  defp uid(nil), do: nil

  defp resolve_localization(nil, _localizations), do: nil

  defp resolve_localization(uid, localizations) do
    Map.get(localizations, uid, uid)
  end

  # ---------------------------------------------------------------------------
  # Entity creation
  # ---------------------------------------------------------------------------

  defp create_record(%{id: id, data: data}, localizations) do
    name_uid = uid(data["DisplayName"])
    description_uid = uid(data["Description"])

    %Spell{
      internalId: id,

      nameUid: name_uid,
      descriptionUid: description_uid,

      name: resolve_localization(
        name_uid,
        localizations
      ),

      description: resolve_localization(
        description_uid,
        localizations
      ),

      level: parse_integer(data["Level"]),
      school: data["SpellSchool"]
    }
  end

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  defp parse_integer(nil), do: nil

  defp parse_integer(value) do
    case Integer.parse(value) do
      {integer, _} ->
        integer

      :error ->
        nil
    end
  end

  # ---------------------------------------------------------------------------
  # Database
  # ---------------------------------------------------------------------------

  defp upsert_records([]), do: {0, nil}

  defp upsert_records(rows) do
    now =
      DateTime.utc_now()
      |> DateTime.truncate(:second)

    rows =
      Enum.map(rows, fn row ->
        %{
          internalId: row.internalId,
          name: row.name,
          nameUid: row.nameUid,
          description: row.description,
          descriptionUid: row.descriptionUid,
          level: row.level,
          school: row.school,
          inserted_at: now,
          updated_at: now
        }
      end)

    Repo.insert_all(
      Spell,
      rows,
      on_conflict: {:replace_all_except, [:id, :inserted_at]},
      conflict_target: [:internalId]
    )
  end

  defp delete_removed_records([]) do
    Repo.delete_all(Spell)
  end

  defp delete_removed_records(rows) do
    internal_ids =
      rows
      |> Enum.map(& &1.internalId)
      |> Enum.uniq()

    from(s in Spell, where: s.internalId not in ^internal_ids)
    |> Repo.delete_all()
  end
end
