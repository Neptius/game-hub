defmodule GameHub.Bg3.XmlReferenceImporter do
  @moduledoc """
  Importe les dieux, personnalités et traits de personnage depuis le fichier
  XML Classes Reworked (General).
  """

  import Ecto.Query
  import SweetXml

  alias GameHub.Bg3.{CharacterTrait, God, Personality}
  alias GameHub.Repo

  @zero_contentuid "0000000000000000000000000000000000000"

  @personality_name_uids [
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

  @character_trait_prefix "h6eb72b35g6633g4642gaf97gc5sd4fd"

  @doc """
  Importe les références depuis un fichier XML.
  """
  def import_file!(path) do
    xml =
      path
      |> File.read!()
      |> parse_xml()

    contents = extract_contents(xml)

    gods = extract_gods(contents)
    personalities = extract_personalities(contents)
    character_traits = extract_character_traits(contents)

    Repo.transaction(fn ->
      upsert_gods!(gods)
      upsert_personalities!(personalities)
      upsert_character_traits!(character_traits)

      delete_stale_gods!(gods)
      delete_stale_personalities!(personalities)
      delete_stale_character_traits!(character_traits)
    end)

    %{
      gods: length(gods),
      personalities: length(personalities),
      character_traits: length(character_traits)
    }
  end

  defp parse_xml(xml) do
    xml
    |> SweetXml.parse()
  end

  defp extract_contents(xml) do
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

  defp clean_text(nil), do: nil

  defp clean_text(text) do
    text
    |> String.trim()
    |> case do
      "" -> nil
      value -> value
    end
  end

  defp extract_personalities(contents) do
    contents
    |> Enum.with_index()
    |> Enum.flat_map(fn {content, index} ->
      if content.contentuid in @personality_name_uids do
        description =
          contents
          |> Enum.at(index + 1)
          |> description_text()

        [
          %{
            contentuid: content.contentuid,
            name: content.text,
            description: description
          }
        ]
      else
        []
      end
    end)
    |> Enum.reject(&is_nil(&1.name))
    |> Enum.uniq_by(& &1.contentuid)
  end

  defp extract_gods(contents) do
    contents
    |> section_contents("GODS AND PERSONALITY")
    |> Enum.drop_while(&(&1.contentuid != "h0160ada8gc451g4c15ga08bg4d6a65202a90"))
    |> Enum.take_while(&(&1.contentuid != @zero_contentuid))
    |> Enum.reject(&(&1.contentuid in @personality_name_uids))
    |> Enum.reject(&personality_description_uid?/1)
    |> Enum.reject(&god_header_or_label?/1)
    |> Enum.reject(&is_nil(&1.text))
    |> Enum.map(fn content ->
      %{
        contentuid: content.contentuid,
        name: content.text
      }
    end)
    |> Enum.uniq_by(& &1.name)
  end

  defp extract_character_traits(contents) do
    contents
    |> section_contents("CHARACTER TRAITS")
    |> Enum.filter(&character_trait?/1)
    |> Enum.map(fn content ->
      %{
        contentuid: content.contentuid,
        name: content.text,
        description: character_trait_description(contents, content.contentuid)
      }
    end)
    |> Enum.reject(&is_nil(&1.name))
    |> Enum.uniq_by(& &1.contentuid)
  end

  defp section_contents(contents, section_name) do
    contents
    |> Enum.chunk_by(fn content ->
      content.contentuid == @zero_contentuid
    end)
    |> Enum.find_value([], fn chunk ->
      if Enum.any?(chunk, &(&1.text == section_name)) do
        chunk
      else
        nil
      end
    end)
  end

  defp character_trait?(%{contentuid: contentuid}) do
    String.starts_with?(contentuid, @character_trait_prefix) and
      character_trait_name_uid?(contentuid)
  end

  defp character_trait_name_uid?(contentuid) do
    suffix = String.replace_prefix(contentuid, @character_trait_prefix, "")

    suffix == "tnone" or Regex.match?(~r/^000\d{2}$/, suffix)
  end

  defp character_trait_description(contents, contentuid) do
    contents
    |> Enum.find_index(&(&1.contentuid == contentuid))
    |> case do
      nil ->
        nil

      index ->
        contents
        |> Enum.at(index + 1)
        |> description_text()
    end
  end

  defp description_text(nil), do: nil

  defp description_text(%{text: text}) do
    case text do
      nil -> nil
      value -> value
    end
  end

  defp personality_description_uid?(%{contentuid: contentuid}) do
    String.contains?(contentuid, "7602ce") or
      String.contains?(contentuid, "7602cf")
  end

  defp god_header_or_label?(%{text: text}) do
    text in [
      "GODS AND PERSONALITY",
      "Personality",
      "Select an additional personality type.",
      "No God"
    ]
  end

  defp upsert_gods!(gods) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    rows =
      Enum.map(gods, fn god ->
        Map.merge(god, %{
          inserted_at: now,
          updated_at: now
        })
      end)

    Repo.insert_all(
      God,
      rows,
      on_conflict: {:replace, [:name, :updated_at]},
      conflict_target: :contentuid
    )
  end

  defp upsert_personalities!(personalities) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    rows =
      Enum.map(personalities, fn personality ->
        Map.merge(personality, %{
          inserted_at: now,
          updated_at: now
        })
      end)

    Repo.insert_all(
      Personality,
      rows,
      on_conflict: {:replace, [:name, :description, :updated_at]},
      conflict_target: :contentuid
    )
  end

  defp upsert_character_traits!(character_traits) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    rows =
      Enum.map(character_traits, fn trait ->
        Map.merge(trait, %{
          inserted_at: now,
          updated_at: now
        })
      end)

    Repo.insert_all(
      CharacterTrait,
      rows,
      on_conflict: {:replace, [:name, :description, :updated_at]},
      conflict_target: :contentuid
    )
  end

  defp delete_stale_gods!(gods) do
    delete_stale!(God, Enum.map(gods, & &1.contentuid))
  end

  defp delete_stale_personalities!(personalities) do
    delete_stale!(Personality, Enum.map(personalities, & &1.contentuid))
  end

  defp delete_stale_character_traits!(character_traits) do
    delete_stale!(CharacterTrait, Enum.map(character_traits, & &1.contentuid))
  end

  defp delete_stale!(schema, contentuids) when contentuids != [] do
    from(record in schema, where: record.contentuid not in ^contentuids)
    |> Repo.delete_all()
  end

  defp delete_stale!(_schema, []), do: :ok
end
