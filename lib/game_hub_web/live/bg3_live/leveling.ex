defmodule GameHub.Bg3.Leveling do
  @moduledoc """
  Logique pure de progression multiclasse par niveau (1 à `max_level/0`).

  Chaque entrée de niveau est une map :

      %{level: 1, class: "Guerrier", subclass: "Champion", feat: nil}

  Cette classe/sous-classe reste figée pour une classe donnée sur toute
  la progression : impossible de reprendre la même classe avec une autre
  sous-classe (contrainte de multiclassage BG3 simplifiée).

  Tous les `feat_interval/0` niveaux pris dans une même classe (4, 8, 12...),
  un don peut être choisi.
  """

  alias GameHub.Bg3.Reference

  @max_level 12
  @feat_interval 4

  @passive_start_level 2
  @passive_interval 4
  @passives_per_slot 2

  def max_level, do: @max_level
  def feat_interval, do: @feat_interval

  @doc """
  Crée une entrée de niveau vide pour le niveau global donné.
  """
  def new_level(level) do
    %{level: level, class: nil, subclass: nil, feat: nil}
  end

  @doc """
  Retourne la liste des niveaux enrichie du niveau de classe cumulé
  et de la présence (ou non) d'un choix de don à ce niveau.

  Chaque entrée retournée contient en plus :
    - `:class_level` — le niveau dans la classe choisie (1, 2, 3...)
    - `:feat_slot?` — vrai si un don peut être choisi à ce niveau
  """
  def compute(levels) do
    {_counts, computed} =
      Enum.reduce(levels, {%{}, []}, fn entry, {counts, acc} ->
        case entry.class do
          nil ->
            computed_entry =
              Map.merge(entry, %{
                class_level: nil,
                feat_slot?: false,
                passive_slot?: false,
                passives: Map.get(entry, :passives, [])
              })

            {counts, [computed_entry | acc]}

          class ->
            class_level = Map.get(counts, class, 0) + 1
            counts = Map.put(counts, class, class_level)

            computed_entry =
              Map.merge(entry, %{
                class_level: class_level,
                feat_slot?: rem(class_level, @feat_interval) == 0,
                passive_slot?: passive_slot?(class_level),
                passives: Map.get(entry, :passives, [])
              })

            {counts, [computed_entry | acc]}
        end
      end)

    Enum.reverse(computed)
  end

  @doc """
  Retourne la sous-classe déjà choisie pour une classe donnée dans la
  progression (nil si la classe n'a pas encore été prise).
  """
  def locked_subclass(levels, class) do
    levels
    |> Enum.find_value(fn
      %{class: ^class, subclass: subclass} when not is_nil(subclass) -> subclass
      _ -> nil
    end)
  end

  @doc """
  Valide la cohérence globale de la progression :
  - une classe ne peut avoir qu'une seule sous-classe sur toute la progression.
  """
  def validate(levels) do
    levels
    |> Enum.filter(& &1.class)
    |> Enum.group_by(& &1.class, & &1.subclass)
    |> Enum.reduce([], fn {class, subclasses}, errors ->
      distinct = subclasses |> Enum.reject(&is_nil/1) |> Enum.uniq()

      if length(distinct) > 1 do
        [
          "La classe #{class} ne peut pas avoir plusieurs sous-classes (#{Enum.join(distinct, ", ")})"
          | errors
        ]
      else
        errors
      end
    end)
  end

  @doc """
  Met à jour la classe choisie pour un niveau donné. Si la classe était
  déjà utilisée ailleurs dans la progression, la sous-classe est
  automatiquement réappliquée (verrouillée). Sinon la sous-classe est
  réinitialisée pour forcer un nouveau choix.
  """
  def put_class(levels, level_number, class) do
    locked_subclass = locked_subclass(levels, class)

    Enum.map(levels, fn
      %{level: ^level_number} = entry ->
        Map.merge(entry, %{
          class: class,
          subclass: locked_subclass,
          feat: nil,
          passives: []
        })

      entry ->
        entry
    end)
  end

  @doc """
  Met à jour la sous-classe choisie pour un niveau donné (uniquement
  autorisé si la classe correspondante n'a pas déjà une sous-classe
  verrouillée par un autre niveau).
  """
  def put_subclass(levels, level_number, subclass) do
    selected_level = Enum.find(levels, &(&1.level == level_number))

    case selected_level do
      %{class: nil} ->
        levels

      %{class: class} ->
        Enum.map(levels, fn entry ->
          if entry.class == class do
            Map.merge(entry, %{subclass: subclass})
          else
            entry
          end
        end)

      nil ->
        levels
    end
  end

  @doc """
  Met à jour le don choisi pour un niveau donné.
  """
  def put_feat(levels, level_number, feat) do
    Enum.map(levels, fn
      %{level: ^level_number} = entry -> Map.merge(entry, %{feat: feat})
      entry -> entry
    end)
  end

  def toggle_passive(levels, level_number, passive) do
    computed_levels = compute(levels)

    case Enum.find(computed_levels, &(&1.level == level_number)) do
      %{class: nil} ->
        levels

      %{passive_slot?: false} ->
        levels

      %{class: class, passives: selected_passives} ->
        available_passives = Reference.passives_for(class)
        selected_passives = selected_passives || []

        if passive not in available_passives do
          levels
        else
          next_passives =
            if passive in selected_passives do
              List.delete(selected_passives, passive)
            else
              if length(selected_passives) < @passives_per_slot do
                selected_passives ++ [passive]
              else
                selected_passives
              end
            end

          Enum.map(levels, fn
            %{level: ^level_number} = entry ->
              Map.merge(entry, %{passives: next_passives})

            entry ->
              entry
          end)
        end

      _ ->
        levels
    end
  end

  def new_level_from_previous(level_number, previous_level) do
    %{
      level: level_number,
      class: previous_level.class,
      subclass: previous_level.subclass,
      feat: nil,
      passives: []
    }
  end

  def ready_for_next_level?(levels) do
    case List.last(levels) do
      %{class: class, subclass: subclass} ->
        present?(class) and present?(subclass)

      _ ->
        false
    end
  end

  defp present?(value) when is_binary(value) do
    String.trim(value) != ""
  end

  defp present?(_value), do: false

  def passive_start_level, do: @passive_start_level
  def passive_interval, do: @passive_interval
  def passives_per_slot, do: @passives_per_slot

  def passive_slot?(class_level)
      when is_integer(class_level) and class_level >= @passive_start_level do
    rem(class_level - @passive_start_level, @passive_interval) == 0
  end

  def passive_slot?(_class_level), do: false
end
