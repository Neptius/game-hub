defmodule GameHubWeb.Bg3Live.Components.AbilityScores do
  @moduledoc """
  Composant d'affichage/édition des caractéristiques (point-buy 27 points,
  bonus raciaux +3/+1) extrait de `CharacterBuilder`.
  """

  use Phoenix.Component

  attr :stat_fields, :list, required: true
  attr :base_scores, :map, required: true
  attr :bonus_primary, :atom, default: nil
  attr :bonus_secondary, :atom, default: nil
  attr :remaining_points, :integer, required: true
  attr :total_points, :integer, required: true
  attr :min_stat, :integer, required: true
  attr :max_stat, :integer, required: true

  def ability_scores(assigns) do
    ~H"""
    <div class="rounded-2xl border border-zinc-800 bg-zinc-900/70 p-4">
      <div class="mb-4 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h2 class="text-lg font-semibold text-white">Caractéristiques</h2>
        </div>

        <div class="rounded-lg border border-amber-500/40 bg-amber-500/10 px-3 py-2 text-sm font-medium text-amber-300">
          <span class="font-bold">{@remaining_points}</span>
          <span class="text-amber-400/70">/ {@total_points}</span>
        </div>
      </div>

      <div class="grid grid-cols-1 gap-1.5">
        <div
          :for={stat <- @stat_fields}
          id={"stat-#{stat}"}
          class="rounded-lg border border-zinc-700 bg-zinc-950/60 px-2 py-1.5 transition hover:border-zinc-500"
        >
          <div class="flex items-center justify-between gap-2">
            <div class="flex w-20 items-baseline gap-2">
              <p class="font-semibold text-white">
                {stat_label(stat)}
              </p>
              <span class="text-xs font-bold text-amber-400">
                {ability_modifier_label(final_score(assigns, stat))}
              </span>
            </div>

            <div class="flex shrink-0 items-center gap-1.5">
              <button
                type="button"
                id={"decrement-#{stat}"}
                phx-click="decrement_stat"
                phx-value-stat={stat}
                disabled={@base_scores[stat] <= @min_stat}
                aria-label={"Diminuer #{stat_label(stat)}"}
                class="flex h-7 w-7 items-center justify-center rounded-md border border-zinc-600 text-base text-zinc-200 transition hover:border-amber-400 hover:text-amber-300 disabled:cursor-not-allowed disabled:opacity-30"
              >
                −
              </button>

              <div class="rounded-md bg-zinc-900 px-2 py-1">
                <span class="text-base font-bold text-white">
                  {final_score(assigns, stat)}
                </span>
              </div>

              <button
                type="button"
                id={"increment-#{stat}"}
                phx-click="increment_stat"
                phx-value-stat={stat}
                disabled={
                  @base_scores[stat] >= @max_stat or
                    @remaining_points < step_cost(@base_scores[stat], :up)
                }
                aria-label={"Augmenter #{stat_label(stat)}"}
                class="flex h-7 w-7 items-center justify-center rounded-md border border-zinc-600 text-base text-zinc-200 transition hover:border-amber-400 hover:text-amber-300 disabled:cursor-not-allowed disabled:opacity-30"
              >
                +
              </button>
            </div>

            <div class="flex shrink-0 items-center gap-1">
              <label class="flex cursor-pointer items-center gap-1 rounded-md border border-zinc-800 px-1.5 py-1 transition hover:border-amber-500/50">
                <input
                  type="checkbox"
                  id={"bonus-primary-#{stat}"}
                  checked={@bonus_primary == stat}
                  phx-click="toggle_bonus"
                  phx-value-bonus="primary"
                  phx-value-stat={stat}
                  aria-label={"Bonus +3 à #{stat_label(stat)}"}
                  class="h-3.5 w-3.5 rounded border-zinc-600 bg-zinc-900 text-amber-500 focus:ring-amber-500"
                />
                <span class="text-[11px] text-amber-400">+3</span>
              </label>

              <label class={[
                "flex items-center gap-1 rounded-md border border-zinc-800 px-1.5 py-1 transition",
                if(
                  @bonus_primary == stat,
                  do: "cursor-not-allowed opacity-40",
                  else: "cursor-pointer hover:border-emerald-500/50"
                )
              ]}>
                <input
                  type="checkbox"
                  id={"bonus-secondary-#{stat}"}
                  checked={@bonus_secondary == stat}
                  disabled={@bonus_primary == stat}
                  phx-click="toggle_bonus"
                  phx-value-bonus="secondary"
                  phx-value-stat={stat}
                  aria-label={"Bonus +1 à #{stat_label(stat)}"}
                  class="h-3.5 w-3.5 rounded border-zinc-600 bg-zinc-900 text-emerald-500 focus:ring-emerald-500 disabled:cursor-not-allowed"
                />
                <span class="text-[11px] text-emerald-400">+1</span>
              </label>
            </div>

            <input
              type="hidden"
              name={"character[#{stat}]"}
              value={final_score(assigns, stat)}
            />
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp final_score(assigns, stat) do
    base = Map.fetch!(assigns.base_scores, stat)

    bonus =
      cond do
        assigns.bonus_primary == stat -> 3
        assigns.bonus_secondary == stat -> 1
        true -> 0
      end

    base + bonus
  end

  defp step_cost(current, :up) do
    cost_table = %{8 => 0, 9 => 1, 10 => 2, 11 => 3, 12 => 4, 13 => 5, 14 => 7, 15 => 9}

    Map.get(cost_table, current + 1, 0) - Map.get(cost_table, current, 0)
  end

  defp ability_modifier(score) when is_integer(score) do
    Integer.floor_div(score - 10, 2)
  end

  defp ability_modifier(_score), do: 0

  defp ability_modifier_label(score) do
    modifier = ability_modifier(score)
    if modifier >= 0, do: "+#{modifier}", else: Integer.to_string(modifier)
  end

  defp stat_label(:strength), do: "STR"
  defp stat_label(:dexterity), do: "DEX"
  defp stat_label(:constitution), do: "CON"
  defp stat_label(:intelligence), do: "INT"
  defp stat_label(:wisdom), do: "WIS"
  defp stat_label(:charisma), do: "CHA"
end
