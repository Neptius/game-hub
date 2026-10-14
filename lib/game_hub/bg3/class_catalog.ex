defmodule GameHub.Bg3.ClassCatalog do
  @moduledoc """
  Index en mémoire des classes et sous-classes (chargées depuis la base) pour
  les lookups utilisés par le builder, sans requête supplémentaire.
  """

  alias GameHub.Bg3.Reference
  alias GameHub.BG3.{Classe, SubClasse}

  defstruct classes: [], classes_by_id: %{}, sub_classes_by_id: %{}

  @type t :: %__MODULE__{
          classes: [%Classe{}],
          classes_by_id: %{integer() => %Classe{}},
          sub_classes_by_id: %{integer() => %SubClasse{}}
        }

  @doc """
  Construit le catalogue à partir de classes avec `sub_classes` préchargées.
  """
  def new(classes) do
    %__MODULE__{
      classes: classes,
      classes_by_id: Map.new(classes, &{&1.id, &1}),
      sub_classes_by_id:
        classes
        |> Enum.flat_map(& &1.sub_classes)
        |> Map.new(&{&1.id, &1})
    }
  end

  def classes(%__MODULE__{classes: classes}), do: classes

  def get_class(%__MODULE__{classes_by_id: index}, id), do: Map.get(index, id)
  def get_sub_class(%__MODULE__{sub_classes_by_id: index}, id), do: Map.get(index, id)

  def class_name(catalog, id), do: name_of(get_class(catalog, id))
  def sub_class_name(catalog, id), do: name_of(get_sub_class(catalog, id))

  def sub_classes_for(_catalog, nil), do: []

  def sub_classes_for(catalog, class_id) do
    case get_class(catalog, class_id) do
      nil -> []
      classe -> classe.sub_classes
    end
  end

  def class_passives_for(_catalog, nil), do: []

  def class_passives_for(catalog, class_id) do
    case get_class(catalog, class_id) do
      nil -> []
      classe -> Reference.class_passives_for(classe.name)
    end
  end

  @doc """
  PV gagnés par un niveau de la classe : `base_hp` au niveau 1 du personnage,
  `hp_per_level` ensuite.
  """
  def hp_gain(catalog, class_id, first_level?) do
    case get_class(catalog, class_id) do
      nil -> 0
      classe when first_level? -> classe.base_hp
      classe -> classe.hp_per_level
    end
  end

  defp name_of(nil), do: nil
  defp name_of(%{name: name}), do: name
end
