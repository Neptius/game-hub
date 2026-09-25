defmodule GameHub.Bg3.XmlReferenceImporter.PersonalityImporter do
  alias GameHub.Bg3.Personality
  alias GameHub.Bg3.XmlReferenceImporter.ImporterHelpers

  @tracked_uids [
    "h6eb72b35g6633g4642gaf97gcca5425bnone",
    "h6eb72b35g6633g4642gaf97gcca5425barba",
    "h6eb72b35g6633g4642gaf97gcca5425nbard",
    "h6eb72b35g6633g4642gaf97gcca542cleric",
    "h6eb72b35g6633g4642gaf97gcca5425druid",
    "h6eb72b35g6633g4642gaf97gcca54fighter",
    "h6eb72b35g6633g4642gaf97gcca5425nmonk",
    "h6eb72b35g6633g4642gaf97gcca542ranger",
    "h6eb72b35g6633g4642gaf97gcca5425rogue",
    "h6eb72b35g6633g4642gaf97gcca5sorcerer",
    "h6eb72b35g6633g4642gaf97gcca54warlock",
    "h6eb72b35g6633g4642gaf97gcca542wizard"
  ]

  def sync!(path) do
    contents = ImporterHelpers.read_contents!(path)
    contents_by_uid = ImporterHelpers.contents_by_uid(contents)

    records =
      Enum.flat_map(@tracked_uids, fn contentuid ->
        case Map.get(contents_by_uid, contentuid) do
          %{text: name} when is_binary(name) ->
            [
              %{
                contentuid: contentuid,
                name: name,
                description:
                  ImporterHelpers.next_content_text(contents, contentuid)
              }
            ]

          _ ->
            []
        end
      end)

    ImporterHelpers.upsert!(
      Personality,
      records,
      [:name, :description, :updated_at]
    )

    deleted =
      ImporterHelpers.delete_untracked_records!(
        Personality,
        records
      )

    %{
      imported: length(records),
      deleted: deleted
    }
  end
end
