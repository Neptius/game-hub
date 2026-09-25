defmodule GameHub.Bg3.XmlReferenceImporter do
  alias GameHub.Bg3.XmlReferenceImporter.{
    CharacterTraitImporter,
    GodImporter,
    PersonalityImporter,
    ArchetypeImporter
  }

  alias GameHub.Repo

  def import_all!(paths) do
    {:ok, result} =
      Repo.transaction(fn ->
        %{
          gods: GodImporter.sync!(paths.gods),
          personalities: PersonalityImporter.sync!(paths.personalities),
          character_traits: CharacterTraitImporter.sync!(paths.character_traits),
          archetypes: ArchetypeImporter.sync!(paths.archetypes)
        }
      end)

    result
  end
end
