defmodule GameHub.Bg3 do
  @moduledoc """
  Context for Baldur's Gate 3 character builds.
  """

  import Ecto.Query, warn: false

  alias GameHub.Bg3.Character
  alias GameHub.Repo

  @doc """
  Returns all saved characters.
  """
  def list_characters do
    Repo.all(Character)
  end

  @doc """
  Gets a single character by id.
  """
  def get_character!(id), do: Repo.get!(Character, id)

  @doc """
  Creates a character.
  """
  def create_character(attrs \\ %{}) do
    %Character{}
    |> Character.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a character.
  """
  def update_character(%Character{} = character, attrs) do
    character
    |> Character.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a character.
  """
  def delete_character(%Character{} = character) do
    Repo.delete(character)
  end

  @doc """
  Returns an changeset for form validation.
  """
  def change_character(%Character{} = character, attrs \\ %{}) do
    Character.changeset(character, attrs)
  end
end
