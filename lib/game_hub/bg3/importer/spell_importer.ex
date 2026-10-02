defmodule GameHub.Bg3.Importer.SpellImporter do
  alias GameHub.Bg3.Spell

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

  def execute do
    @txt_paths
    |> Enum.flat_map(&parse_file/1)

  end

  defp upsert(attrs) do
    %Spell{}
    |> Spell.changeset(attrs)
    |> GameHub.Repo.insert(
      on_conflict: {:replace_all_except, [:id, :inserted_at]},
      conflict_target: :contentuid
    )
  end

  defp sync do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    rows =
      Enum.map(records, fn record ->
        Map.merge(record, %{
          inserted_at: now,
          updated_at: now
        })
      end)

    Repo.insert_all(
      schema,
      rows,
      on_conflict: {:replace, fields},
      conflict_target: :contentuid
    )



    deleted =
      delete_untracked_records!(
        Personality,
        records
      )

    %{
      imported: length(records),
      deleted: deleted
    }
  end

  def upsert!(schema, records, fields) do
  end

  def delete_untracked_records!(schema, imported_records) do
    imported_contentuids = Enum.map(imported_records, & &1.contentuid)

    query =
      if imported_contentuids == [] do
        from(record in schema)
      else
        from record in schema,
          where: record.contentuid not in ^imported_contentuids
      end

    {deleted_count, _} = Repo.delete_all(query)
    deleted_count
  end

  defp parse_file(path) do
    path
    |> File.read!()
    |> String.split(~r/\R/)
    |> Enum.reduce([], &parse_line/2)
    |> Enum.filter(& &1.data["Level"])
    |> Enum.reverse()
  end

  defp parse_line(line, []) do
    case Regex.run(~r/^new entry "([^"]+)"/, String.trim(line)) do
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
        [id] = Regex.run(~r/^new entry "([^"]+)"/, line, capture: :all_but_first)

        [%{id: id, data: %{}} | [current | rest]]

      # Regex.match?(~r/^type "/, line) ->
      #   [type] =
      #     Regex.run(~r/^type "([^"]+)"/, line, capture: :all_but_first)

      #   [%{current | type: type} | rest]

      Regex.match?(~r/^data "/, line) ->
        case Regex.run(~r/^data "([^"]+)" "(.*)"$/, line, capture: :all_but_first) do
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
end
