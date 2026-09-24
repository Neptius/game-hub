defmodule Mix.Tasks.Bg3.ImportReferences do
  use Mix.Task

  @shortdoc "Importe les dieux, personnalités et traits BG3 depuis le XML"

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    path =
      case args do
        [xml_path] ->
          xml_path

        [] ->
          "./uploads/BG3/Mods/HomeBrew-extracted/Mods/HomeBrew - Comprehensive Reworks/Localization/English/Classes Reworked (General).xml"

        _ ->
          Mix.raise("Usage: mix bg3.import_references [chemin_du_fichier_xml]")
      end

    unless File.exists?(path) do
      Mix.raise("Fichier XML introuvable : #{path}")
    end

    IO.puts("Import du fichier : #{path}")

    result = GameHub.Bg3.XmlReferenceImporter.import_file!(path)

    IO.puts("""
    Import terminé :
      Dieux : #{result.gods}
      Personnalités : #{result.personalities}
      Traits : #{result.character_traits}
    """)
  end
end
