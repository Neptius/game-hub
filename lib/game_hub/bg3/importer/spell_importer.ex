defmodule GameHub.Bg3.Importer.SpellImporter do
  alias GameHub.Bg3.Importer.ImporterHelpers


  def execute do
    xml_paths = [
      "./uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Spells Reworked - 5e Integration.xml",
      "./uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Spells Reworked - Dawnstar Integration.xml",
      "./uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Spells Reworked.xml"
    ]

    txt_paths = [
      "./uploads/BG3/Mods/HomeBrew-extracted/Public/HomeBrew - Comprehensive Reworks/Stats/Generated/Data/Spells Reworked - Spell_Projectile.txt",
      "./uploads/BG3/Mods/HomeBrew-extracted/Public/HomeBrew - Comprehensive Reworks/Stats/Generated/Data/Spells Reworked - Spell_Rush.txt",
      "./uploads/BG3/Mods/HomeBrew-extracted/Public/HomeBrew - Comprehensive Reworks/Stats/Generated/Data/Spells Reworked - Spell_Shout.txt",
      "./uploads/BG3/Mods/HomeBrew-extracted/Public/HomeBrew - Comprehensive Reworks/Stats/Generated/Data/Spells Reworked - Spell_Target.txt",
      "./uploads/BG3/Mods/HomeBrew-extracted/Public/HomeBrew - Comprehensive Reworks/Stats/Generated/Data/Spells Reworked - Spell_Teleportation.txt",
      "./uploads/BG3/Mods/HomeBrew-extracted/Public/HomeBrew - Comprehensive Reworks/Stats/Generated/Data/Spells Reworked - Spell_Throw.txt",
      "./uploads/BG3/Mods/HomeBrew-extracted/Public/HomeBrew - Comprehensive Reworks/Stats/Generated/Data/Spells Reworked - Spell_Wall.txt",
      "./uploads/BG3/Mods/HomeBrew-extracted/Public/HomeBrew - Comprehensive Reworks/Stats/Generated/Data/Spells Reworked - Spell_Zone.txt"
    ]
  end
end
