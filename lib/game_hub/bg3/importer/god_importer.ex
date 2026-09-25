defmodule GameHub.Bg3.XmlReferenceImporter.GodImporter do
  alias GameHub.Bg3.God
  alias GameHub.Bg3.XmlReferenceImporter.ImporterHelpers

  @tracked_uids [
    "h6eb72b35g6633g4642gaf97gcca5425nogod",
    "h0160ada8gc451g4c15ga08bg4d6a65202a90",
    "h2e52ac7dg2619g4f6dgb3c0g4ec3a4e83b09",
    "h3723f319g29dfg46a3g8745g6a2cc64c9b37",
    "h3dd583fag3348g4e4agab02g0df9aaf664be",
    "h3ea30052ga0fbg413cgb7adg1b45bc32d9c2",
    "h3f7a3486g7ecbg49c1g8aaaga27b791f6b18",
    "h40e4943ag93d4g4a14g8876g5df8578ac476",
    "h424dcdc3g3e2bg489bga3e7g9b88a5b658f1",
    "h661e3b22gf74cg4952g950ag555a443dec3d",
    "h6830c2acg119dg4aecg846dg685829f9e98f",
    "h6f2ed899g25deg45e0gbfa1gdbd0b30d50cc",
    "h78970a10ga684g4c82g8f2fgc61e1ec08039",
    "h790eaa77ge697g49a8g8d8ag6836896c5f1a",
    "h831a99dcg5137g4a4cgb8b9gaa3ef736a35c",
    "h8d7cf36eg3db9g4885gbabeg75d12b6951dd",
    "h91bdb028gffbcg4f0egbc44g39fee27fed7f",
    "ha1cddb35gcd4fg4d37gb3bcgc3913d2b2338",
    "ha7fbb66bgfe19g4a30gaceeg14e2a546fe55",
    "hac9b42b6g0fafg4053g850bgdd3d4e0b2268",
    "hae70879agd7f7g4281ga84cgf942e5f07a64",
    "hb455b695g66abg46a3g81c3g5c4e4e1e7b16",
    "hbb146368g6f1bg4d90gb5a9g89a6a9821025",
    "hbe4de057g8105g420fg9d83gf02a15a12d3b",
    "hbee34fd4gb359g42a9gbb76g1aa6aa53d87c",
    "hc9cbfccdg24e3g4416g80feg9e2831319847",
    "hca4b5645ge53fg4d13g84b7gf05e026c133b",
    "hcb2af586gb16cg4566gbb69ge1e39bb45666",
    "hd5559499geed3g4675g9172g7b0ad360cde4",
    "he2163839gec02g49dfg867dge95799dac6fe",
    "hebee59dfg9440g4c04ga787g8125a2c48636",
    "hf6050ef3g4121g4975g8ce5gf645ef79a7b6",
    "hf9671c0egeb44g4c08g870dg3a4513e81ebb"
  ]

  def sync!(path) do
    contents = ImporterHelpers.read_contents!(path)
    contents_by_uid = ImporterHelpers.contents_by_uid(contents)

    records =
      @tracked_uids
      |> Enum.flat_map(fn contentuid ->
        case Map.get(contents_by_uid, contentuid) do
          %{text: name} when is_binary(name) ->
            [%{contentuid: contentuid, name: name}]

          _ ->
            []
        end
      end)

    ImporterHelpers.upsert!(
      God,
      records,
      [:name, :updated_at]
    )

    deleted =
      ImporterHelpers.delete_untracked_records!(
        God,
        records
      )

    %{
      imported: length(records),
      deleted: deleted
    }
  end
end
