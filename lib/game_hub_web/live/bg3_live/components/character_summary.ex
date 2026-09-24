defmodule GameHubWeb.Bg3Live.Components.CharacterSummary do
  @moduledoc """
  Panneau de récapitulatif (niveau, classes, PV, initiative) affiché en
  sticky à côté du formulaire de création/édition de personnage.
  """

  use Phoenix.Component

  @base_hp 36
  @hp_per_level 6

  attr :progression, :list, required: true
  attr :base_scores, :map, required: true
  attr :bonus_primary, :atom, default: nil
  attr :bonus_secondary, :atom, default: nil

  def character_summary(assigns) do
    max_level = length(assigns.progression)
    class_levels = class_level_counts(assigns.progression)

    constitution = final_score(assigns, :constitution)
    dexterity = final_score(assigns, :dexterity)
    wisdom = final_score(assigns, :wisdom)

    hp = compute_hp(max_level, constitution)
    initiative = ability_modifier(dexterity) + ability_modifier(wisdom)

    assigns =
      assigns
      |> assign(:max_level, max_level)
      |> assign(:class_levels, class_levels)
      |> assign(:hp, hp)
      |> assign(:initiative, initiative)

    ~H"""
    <div class="rounded-2xl border border-zinc-800 bg-zinc-900/80 p-6 shadow-xl shadow-zinc-950/30">
      <h2 class="text-lg font-semibold text-white">Récapitulatif</h2>

      <div class="mt-4 flex items-center justify-between rounded-xl bg-zinc-950/60 px-4 py-3">
        <span class="text-sm text-zinc-400">Niveau</span>
        <span class="text-2xl font-bold text-amber-400">{@max_level}</span>
      </div>

      <div class="mt-4">
        <p class="mb-2 text-xs uppercase tracking-wide text-zinc-500">Classes</p>

        <div :if={@class_levels == []} class="text-sm text-zinc-500">
          Aucune classe sélectionnée
        </div>

        <ul class="space-y-1">
          <li
            :for={{class, level} <- @class_levels}
            class="flex items-center justify-between rounded-lg bg-zinc-950/40 px-3 py-1.5 text-sm"
          >
            <span class="text-zinc-300">{class}</span>
            <span class="font-semibold text-white">{level}</span>
          </li>
        </ul>
      </div>

      <div class="mt-5 grid grid-cols-2 gap-3">
        <div class="rounded-xl bg-zinc-950/60 p-3 text-center">
          <p class="text-xs uppercase tracking-wide text-zinc-500">PV</p>
          <p class="mt-1 text-2xl font-bold text-emerald-400">{@hp}</p>
        </div>

        <div class="rounded-xl bg-zinc-950/60 p-3 text-center">
          <p class="text-xs uppercase tracking-wide text-zinc-500">Initiative</p>
          <p class="mt-1 text-2xl font-bold text-sky-400">
            {modifier_label(@initiative)}
          </p>
        </div>
      </div>
    </div>
    """
  end

  defp class_level_counts(progression) do
    progression
    |> Enum.filter(& &1.class)
    |> Enum.reduce(%{}, fn entry, acc ->
      Map.update(acc, entry.class, 1, &(&1 + 1))
    end)
    |> Enum.sort_by(fn {_class, level} -> -level end)
  end

  defp compute_hp(0, _constitution), do: 0

  defp compute_hp(max_level, constitution) do
    con_modifier = ability_modifier(constitution)

    @base_hp + (max_level - 1) * @hp_per_level + max_level * con_modifier
  end

  defp final_score(assigns, stat) do
    base = Map.get(assigns.base_scores, stat, 8)

    bonus =
      cond do
        assigns.bonus_primary == stat -> 3
        assigns.bonus_secondary == stat -> 1
        true -> 0
      end

    base + bonus
  end

  defp ability_modifier(score) when is_integer(score) do
    Integer.floor_div(score - 10, 2)
  end

  defp ability_modifier(_score), do: 0

  defp modifier_label(modifier) when modifier >= 0, do: "+#{modifier}"
  defp modifier_label(modifier), do: Integer.to_string(modifier)
end
