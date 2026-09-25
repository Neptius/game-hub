defmodule GameHub.Bg3.XmlReferenceImporter.ImporterHelpers do
  import Ecto.Query
  import SweetXml

  alias GameHub.Repo

  def read_contents!(path) do
    path
    |> File.read!()
    |> SweetXml.parse()
    |> extract_contents()
  end

  def extract_contents(xml) do
    xml
    |> xpath(~x"//contentList/content"l,
      contentuid: ~x"./@contentuid"s,
      text: ~x"./text()"s
    )
    |> Enum.map(fn content ->
      %{
        contentuid: String.trim(content.contentuid),
        text: clean_text(content.text)
      }
    end)
  end

  def contents_by_uid(contents) do
    Map.new(contents, &{&1.contentuid, &1})
  end

  def next_content_text(contents, contentuid) do
    case Enum.find_index(contents, &(&1.contentuid == contentuid)) do
      nil ->
        nil

      index ->
        case Enum.at(contents, index + 1) do
          %{text: text} -> text
          _ -> nil
        end
    end
  end

  def upsert!(schema, records, fields) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    rows =
      Enum.map(records, fn record ->
        Map.merge(record, %{
          inserted_at: now,
          updated_at: now
        })
      end)

    Repo.insert_all(
      schema,
      rows,
      on_conflict: {:replace, fields},
      conflict_target: :contentuid
    )
  end

  def delete_untracked_records!(schema, imported_records) do
    imported_contentuids = Enum.map(imported_records, & &1.contentuid)

    query =
      if imported_contentuids == [] do
        from record in schema
      else
        from record in schema,
          where: record.contentuid not in ^imported_contentuids
      end

    {deleted_count, _} = Repo.delete_all(query)
    deleted_count
  end

  defp clean_text(nil), do: nil

  defp clean_text(text) do
    text
    |> String.trim()
    |> String.replace(~r/<LSTag\b[^>]*>/iu, "")
    |> String.replace(~r/<\/LSTag>/iu, "")
    |> String.replace(~r/<br\s*\/?>/iu, "\n\n")
    |> String.replace(~r/<\/?i>/iu, "")
    |> String.replace(~r/<[^>]+>/u, "")
    |> String.replace(~r/[ \t]+/u, " ")
    |> String.replace(~r/\n[ \t]+/u, "\n")
    |> String.replace(~r/\n{3,}/u, "\n\n")
    |> String.trim()
    |> case do
      "" -> nil
      value -> value
    end
  end
end
