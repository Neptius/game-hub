defmodule GameHub.Bg3.Importer.SpellImporter do
  import SweetXml

  alias GameHub.Bg3.Importer.ImportHelpers

  @xml_paths [
    "./uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Spells Reworked.xml",
    "./uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Spells Reworked - 5e Integration.xml",
    "./uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Spells Reworked - Dawnstar Integration.xml"
  ]

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

  def execute do
    path = "./uploads/BG3/Mods/HomeBrew-extracted/Public/HomeBrew - Comprehensive Reworks/Stats/Generated/Data/Spells Reworked - Spell_Projectile.txt"

    path
    |> File.read!()
    |> String.split(~r/\R/)
    |> Enum.reduce([], &parse_line/2)
    |> Enum.filter(&(&1.data["Level"]))
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
