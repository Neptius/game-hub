defmodule Mix.Tasks.Bg3.ImportReferences do
  use Mix.Task

  @shortdoc "Importe les références BG3 depuis plusieurs fichiers XML"

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")

    paths = %{
      gods:
        "./uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Classes Reworked (General).xml",
      personalities:
        "./uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Classes Reworked (General).xml",
      character_traits:
        "./uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Classes Reworked (General).xml"
    }

    result = GameHub.Bg3.XmlReferenceImporter.import_all!(paths)

    IO.inspect(result, label: "Import terminé")
  end
end
