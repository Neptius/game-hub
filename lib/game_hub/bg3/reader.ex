defmodule GameHub.Bg3.Pak.Reader do
  @moduledoc """
  Module responsible for reading and parsing BG3 .pak files.
  """

  import Bitwise

  @header_size 40

  # OPEN

  def open(path) do
    with {:ok, file} <- File.open(path, [:read, :binary]),
         {:ok, header} <- read_header(file),
         {:ok, entries} <- read_file_list(file, header) do
      File.close(file)

      {:ok,
       %{
         path: path,
         header: header,
         entries: entries
       }}
    else
      {:error, _reason} = error ->
        error
    end
  end

  defp read_header(file) do
    case :file.read(file, @header_size) do
      {:ok,
       <<
         "LSPK",
         version::little-32,
         file_list_offset::little-64,
         file_list_size::little-32,
         flags::8,
         priority::8,
         md5::binary-size(16),
         num_parts::little-16
       >>} ->
        {:ok,
         %{
           version: version,
           file_list_offset: file_list_offset,
           file_list_size: file_list_size,
           flags: flags,
           priority: priority,
           md5: md5,
           num_parts: num_parts
         }}

      {:ok, _} ->
        {:error, :invalid_header}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp read_file_list(file, header) do
    {:ok, _} = :file.position(file, {:bof, header.file_list_offset})

    with {:ok, <<num_files::little-32, compressed_size::little-32>>} <- :file.read(file, 8),
         {:ok, compressed} <- :file.read(file, compressed_size),
         {:ok, decompressed} <- decompress_file_list(compressed, num_files) do
      entries = parse_entries(decompressed, num_files)

      {:ok, entries}
    end
  end

  defp decompress_file_list(compressed, num_files) do
    expected_size = num_files * 272

    case NimbleLZ4.decompress(compressed, expected_size) do
      {:ok, data} ->
        {:ok, data}

      {:error, reason} ->
        {:error, {:lz4_error, reason}}
    end
  end

  defp parse_entries(binary, num_files) do
    for <<entry::binary-size(272) <- binary>> do
      parse_entry(entry)
    end
    |> Enum.take(num_files)
  end

  defp parse_entry(<<
         name::binary-size(256),
         offset_low::little-32,
         offset_high::little-16,
         archive_part::8,
         flags::8,
         size_on_disk::little-32,
         uncompressed_size::little-32
       >>) do
    %{
      name: name |> :binary.split(<<0>>, [:global]) |> hd(),
      offset: offset_low ||| offset_high <<< 32,
      archive_part: archive_part,
      flags: flags,
      size_on_disk: size_on_disk,
      uncompressed_size: uncompressed_size
    }
  end

  # READ

  def read(pak, name) when is_binary(name) do
    case Enum.find(pak.entries, &(&1.name == name)) do
      nil ->
        {:error, {:file_not_found, name}}

      entry ->
        read(pak, entry)
    end
  end

  def read(pak, entry) do
    read_entry(pak, entry)
  end

  defp read_entry(pak, entry) do
    with {:ok, file} <- File.open(pak.path, [:read, :binary]),
         {:ok, data} <- read_entry_data(file, entry) do
      File.close(file)

      decompress(data, entry)
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp read_entry_data(file, entry) do
    {:ok, _position} =
      :file.position(file, {:bof, entry.offset})

    case :file.read(file, entry.size_on_disk) do
      {:ok, data} ->
        {:ok, data}

      {:error, reason} ->
        {:error, {:read_error, reason}}
    end
  end

  defp decompress(data, %{flags: flags, uncompressed_size: expected_size}) do
    method = compression_method(flags)

    case method do
      :none ->
        {:ok, data}

      :lz4 ->
        decompress_lz4(data, expected_size)

      :zlib ->
        decompress_zlib(data, expected_size)

      :zstd ->
        decompress_zstd(data, expected_size)

      :unknown ->
        {:error, {:unsupported_compression, flags}}
    end
  end

  defp compression_method(flags) do
    case flags &&& 0x0F do
      0 -> :none
      1 -> :zlib
      2 -> :lz4
      3 -> :zstd
      _ -> :unknown
    end
  end

  defp decompress_lz4(data, expected_size) do
    case NimbleLZ4.decompress(data, expected_size) do
      {:ok, result} ->
        {:ok, result}

      result when is_binary(result) ->
        {:ok, result}

      {:error, reason} ->
        {:error, {:lz4_error, reason}}
    end
  end

  defp decompress_zlib(data, expected_size) do
    try do
      result = :zlib.uncompress(data)

      if byte_size(result) == expected_size do
        {:ok, result}
      else
        {:error, {:invalid_size, byte_size(result), expected_size}}
      end
    rescue
      error ->
        {:error, {:zlib_error, error}}
    end
  end

  defp decompress_zstd(data, expected_size) do
    case :ezstd.decompress(data) do
      {:ok, result} ->
        if byte_size(result) == expected_size do
          {:ok, result}
        else
          {:error, {:invalid_size, byte_size(result), expected_size}}
        end

      result when is_binary(result) ->
        if byte_size(result) == expected_size do
          {:ok, result}
        else
          {:error, {:invalid_size, byte_size(result), expected_size}}
        end

      {:error, reason} ->
        {:error, {:zstd_error, reason}}
    end
  end
end
