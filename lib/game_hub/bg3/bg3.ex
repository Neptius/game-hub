defmodule GameHub.Bg3 do
  @moduledoc """
  Context for Baldur's Gate 3 character builds.
  """

  import Ecto.Query, warn: false

  alias GameHub.Bg3.{Character, ClassCatalog}
  alias GameHub.BG3.{Classe, SubClasse}
  alias GameHub.Repo

  @doc """
  Returns all classes (ordered by name) with their sub-classes preloaded.
  """
  def list_classes do
    sub_classes = from(sc in SubClasse, order_by: sc.name)

    Classe
    |> order_by([c], c.name)
    |> preload(sub_classes: ^sub_classes)
    |> Repo.all()
  end

  @doc """
  Returns an in-memory catalog of classes and sub-classes.
  """
  def class_catalog, do: ClassCatalog.new(list_classes())

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
