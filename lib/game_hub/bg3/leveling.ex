defmodule GameHub.Bg3.Leveling do
  alias GameHub.Bg3.Reference

  @max_level 12
  @feat_interval 4
  @class_passive_start_level 2
  @class_passive_interval 4
  @class_passives_per_slot 2

  def max_level, do: @max_level
  def feat_interval, do: @feat_interval
  def class_passive_start_level, do: @class_passive_start_level
  def class_passive_interval, do: @class_passive_interval
  def class_passives_per_slot, do: @class_passives_per_slot

  def new_level(level) do
    %{
      level: level,
      class_id: nil,
      subclass_id: nil,
      feat: nil,
      class_passive_ids: []
    }
  end

  def new_level_from_previous(level_number, previous_level) do
    %{
      level: level_number,
      class_id: previous_level.class_id,
      subclass_id: previous_level.subclass_id,
      feat: nil,
      class_passive_ids: []
    }
  end

  def class_passive_slot?(class_level)
      when is_integer(class_level) and class_level >= @class_passive_start_level do
    rem(class_level - @class_passive_start_level, @class_passive_interval) == 0
  end

  def class_passive_slot?(_class_level), do: false

  def compute(levels) do
    {_counts, computed} =
      Enum.reduce(levels, {%{}, []}, fn entry, {counts, acc} ->
        case entry.class_id do
          nil ->
            computed_entry =
              Map.merge(entry, %{
                class_level: nil,
                feat_slot?: false,
                class_passive_slot?: false,
                class_passive_ids: Map.get(entry, :class_passive_ids, [])
              })

            {counts, [computed_entry | acc]}

          class_id ->
            class_level = Map.get(counts, class_id, 0) + 1
            counts = Map.put(counts, class_id, class_level)

            computed_entry =
              Map.merge(entry, %{
                class_level: class_level,
                feat_slot?: rem(class_level, @feat_interval) == 0,
                class_passive_slot?: class_passive_slot?(class_level),
                class_passive_ids: Map.get(entry, :class_passive_ids, [])
              })

            {counts, [computed_entry | acc]}
        end
      end)

    Enum.reverse(computed)
  end

  def locked_subclass_id(levels, class_id) do
    Enum.find_value(levels, fn
      %{class_id: ^class_id, subclass_id: subclass_id} when not is_nil(subclass_id) ->
        subclass_id

      _ ->
        nil
    end)
  end

  def validate(levels) do
    levels
    |> Enum.filter(& &1.class_id)
    |> Enum.group_by(& &1.class_id, & &1.subclass_id)
    |> Enum.reduce([], fn {class_id, subclass_ids}, errors ->
      distinct = subclass_ids |> Enum.reject(&is_nil/1) |> Enum.uniq()

      if length(distinct) > 1 do
        class_name = Reference.class_name(class_id)

        [
          "La classe #{class_name} ne peut pas avoir plusieurs sous-classes"
          | errors
        ]
      else
        errors
      end
    end)
  end

  def ready_for_next_level?(levels) do
    case List.last(levels) do
      %{class_id: class_id, subclass_id: subclass_id} ->
        not is_nil(class_id) and not is_nil(subclass_id)

      _ ->
        false
    end
  end

  def put_class(levels, level_number, class_id) do
    locked_subclass_id = locked_subclass_id(levels, class_id)

    Enum.map(levels, fn
      %{level: ^level_number} = entry ->
        Map.merge(entry, %{
          class_id: class_id,
          subclass_id: locked_subclass_id,
          feat: nil,
          class_passive_ids: []
        })

      entry ->
        entry
    end)
  end

  def put_subclass(levels, level_number, subclass_id) do
    selected_level = Enum.find(levels, &(&1.level == level_number))

    case selected_level do
      %{class_id: nil} ->
        levels

      %{class_id: class_id} ->
        Enum.map(levels, fn entry ->
          if entry.class_id == class_id do
            Map.merge(entry, %{subclass_id: subclass_id})
          else
            entry
          end
        end)

      nil ->
        levels
    end
  end

  def put_feat(levels, level_number, feat) do
    Enum.map(levels, fn
      %{level: ^level_number} = entry -> Map.merge(entry, %{feat: feat})
      entry -> entry
    end)
  end

  def toggle_class_passive(levels, level_number, class_passive_id) do
    computed_levels = compute(levels)

    case Enum.find(computed_levels, &(&1.level == level_number)) do
      %{class_id: nil} ->
        levels

      %{class_passive_slot?: false} ->
        levels

      %{class_id: class_id, class_passive_ids: selected_ids} ->
        available_ids =
          Reference.class_passives_for(class_id) |> Enum.map(& &1.id)

        selected_ids = selected_ids || []

        taken_elsewhere =
          computed_levels
          |> Enum.filter(&(&1.class_id == class_id and &1.level != level_number))
          |> Enum.flat_map(&Map.get(&1, :class_passive_ids, []))

        cond do
          class_passive_id not in available_ids ->
            levels

          class_passive_id in selected_ids ->
            next_ids = List.delete(selected_ids, class_passive_id)
            apply_class_passives(levels, level_number, next_ids)

          class_passive_id in taken_elsewhere ->
            levels

          length(selected_ids) >= @class_passives_per_slot ->
            levels

          true ->
            next_ids = selected_ids ++ [class_passive_id]
            apply_class_passives(levels, level_number, next_ids)
        end

      _ ->
        levels
    end
  end

  defp apply_class_passives(levels, level_number, class_passive_ids) do
    Enum.map(levels, fn
      %{level: ^level_number} = entry ->
        Map.merge(entry, %{class_passive_ids: class_passive_ids})

      entry ->
        entry
    end)
  end
end
