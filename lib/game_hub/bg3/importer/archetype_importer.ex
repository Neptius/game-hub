defmodule GameHub.Bg3.XmlReferenceImporter.ArchetypeImporter do
  alias GameHub.Bg3.Archetype
  alias GameHub.Bg3.XmlReferenceImporter.ImporterHelpers

  @tracked_uids [
    "h6eb72b35g6633g4642gaf97gc5sarchety00",
    "h6eb72b35g6633g4642gaf97gc5sarchety01",
    "h6eb72b35g6633g4642gaf97gc5sarchety16",
    "h6eb72b35g6633g4642gaf97gc5sarchety02",
    "h6eb72b35g6633g4642gaf97gc5sarchety12",
    "h6eb72b35g6633g4642gaf97gc5sarchety03",
    "h6eb72b35g6633g4642gaf97gc5sarchety19",
    "h6eb72b35g6633g4642gaf97gc5sarchety11",
    "h6eb72b35g6633g4642gaf97gc5sarchety04",
    "h6eb72b35g6633g4642gaf97gc5sarchety05",
    "h6eb72b35g6633g4642gaf97gc5sarchety14",
    "h6eb72b35g6633g4642gaf97gc5sarchety18",
    "h6eb72b35g6633g4642gaf97gc5sarchety06",
    "h6eb72b35g6633g4642gaf97gc5sarchety17",
    "h6eb72b35g6633g4642gaf97gc5sarchety13",
    "h6eb72b35g6633g4642gaf97gc5sarchety20",
    "h6eb72b35g6633g4642gaf97gc5sarchety07",
    "h6eb72b35g6633g4642gaf97gc5sarchety08",
    "h6eb72b35g6633g4642gaf97gc5sarchety09",
    "h6eb72b35g6633g4642gaf97gc5sarchety15",
    "h6eb72b35g6633g4642gaf97gc5sarchety10"
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
      Archetype,
      records,
      [:name, :description, :updated_at]
    )

    deleted =
      ImporterHelpers.delete_untracked_records!(
        Archetype,
        records
      )

    %{
      imported: length(records),
      deleted: deleted
    }
  end
end
