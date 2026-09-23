defmodule GameHub.BG3.Pak.Extractor do
  @moduledoc """
  Module responsible for extracting data from BG3 .pak files.
  """

  alias GameHub.BG3.Pak.Reader

  def start do
    GameHub.BG3.Pak.Extractor.extract(
      "./uploads/BG3/Mods/HomeBrew - Comprehensive Reworks.pak",
      "./uploads/BG3/Mods/HomeBrew-extracted"
    )
  end

  def debug do
    {:ok, pak} =
      GameHub.BG3.Pak.Reader.open("./uploads/BG3/Mods/HomeBrew - Comprehensive Reworks.pak")

    {:ok, data} =
      GameHub.BG3.Pak.Reader.read(
        pak,
        "Mods/HomeBrew - Comprehensive Reworks/meta.lsx"
      )

    IO.puts(data)
  end

  # def debug_entry do
  #   path = "./uploads/HomeBrew - Comprehensive Reworks.pak"

  #   {:ok, file} = File.open(path, [:read, :binary])

  #   {:ok, _} =
  #     :file.position(
  #       file,
  #       {:bof, 470_924_264}
  #     )

  #   {:ok, data} = :file.read(file, 272)

  #   IO.inspect(data, base: :hex, label: "entry")

  #   File.close(file)
  # end

  def extract(pak_path, output_dir) do
    with {:ok, pak} <- Reader.open(pak_path),
         :ok <- File.mkdir_p(output_dir) do
      total = length(pak.entries)

      pak.entries
      |> Enum.with_index(1)
      |> Enum.each(fn {entry, index} ->
        IO.puts("[#{index}/#{total}] #{entry.name}")

        case Reader.read(pak, entry) do
          {:ok, data} ->
            write_entry(output_dir, entry.name, data)

          {:error, reason} ->
            IO.puts("  ERROR: #{inspect(reason)}")
        end
      end)

      {:ok, pak}
    end
  end

  defp write_entry(output_dir, name, data) do
    path = Path.join(output_dir, name)

    path
    |> Path.dirname()
    |> File.mkdir_p!()

    File.write!(path, data)
  end
end
