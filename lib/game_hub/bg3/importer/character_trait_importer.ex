defmodule GameHub.Bg3.XmlReferenceImporter.CharacterTraitImporter do
  alias GameHub.Bg3.CharacterTrait
  alias GameHub.Bg3.XmlReferenceImporter.ImporterHelpers

  @tracked_uids [
    "h6eb72b35g6633g4642gaf97gc5sd4fdtnone",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00001",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00002",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00003",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00004",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00005",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00006",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00007",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00008",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00009",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00010",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00011",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00012",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00013",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00014",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00015",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00016",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00017",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00018",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00019",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00020",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00021",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00022",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00023",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00024",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00025",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00026",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00027",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00028",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00029",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00030",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00031",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00032",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00033",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00034",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00035",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00036",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00037",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00038",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00039",
    "h6eb72b35g6633g4642gaf97gc5sd4fd00040"
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
      CharacterTrait,
      records,
      [:name, :description, :updated_at]
    )

    deleted =
      ImporterHelpers.delete_untracked_records!(
        CharacterTrait,
        records
      )

    %{
      imported: length(records),
      deleted: deleted
    }
  end
end
