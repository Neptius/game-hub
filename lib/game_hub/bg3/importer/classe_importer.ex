defmodule GameHub.BG3.Importer.ClasseImporter do
  alias GameHub.BG3.Classe
  alias GameHub.Repo

  import Ecto.Query
  import SweetXml

  @lsx_paths [
    "/Users/aymeric/Documents/Dev/Perso/game_hub/uploads/BG3/Mods/HomeBrew-extracted/Public/HomeBrew - Comprehensive Reworks/ClassDescriptions/ClassDescriptions.lsx"
  ]

  @xml_paths [
    "/Users/aymeric/Documents/Dev/Perso/game_hub/uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Classes Reworked (Artificier).xml",
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
    # localizations = load_localizations()
    @lsx_paths
    |> Enum.flat_map(&read_contents!/1)

    # end)
  end

  defp read_contents!(path) do
    path
    |> File.read!()
    |> SweetXml.parse()
    |> extract_contents()
  end

  defp extract_contents(parsed_xml) do
    parsed_xml
    |> xpath(~x"//node[@id='ClassDescription']"l)
  end

  defp upsert_records(rows) do
  end

  defp delete_removed_records(rows) do
  end
end
