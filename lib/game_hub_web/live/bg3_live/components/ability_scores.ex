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
    <div class="rounded-2xl border border-zinc-800 bg-zinc-900/70 p-6">
      <div class="mb-5 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h2 class="text-xl font-semibold text-white">Caractéristiques</h2>
          <p class="mt-1 text-sm text-zinc-400">
            Répartissez vos {@total_points} points entre les six caractéristiques.
          </p>
        </div>

        <div class="rounded-lg border border-amber-500/40 bg-amber-500/10 px-3 py-2 text-sm font-medium text-amber-300">
          Points restants : <span class="font-bold">{@remaining_points}</span>
          <span class="text-amber-400/70">/ {@total_points}</span>
        </div>
      </div>

      <div class="space-y-3">
        <div
          :for={stat <- @stat_fields}
          id={"stat-#{stat}"}
          class="rounded-xl border border-zinc-700 bg-zinc-950/60 p-4 transition hover:border-zinc-500"
        >
          <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
            <div class="min-w-0">
              <p class="font-semibold text-white">{stat_label(stat)}</p>

              <p class="mt-1 text-xs text-zinc-500">
                Base : {@base_scores[stat]}

                <span
                  :if={@bonus_primary == stat}
                  class="ml-2 font-medium text-amber-400"
                >
                  Bonus racial +3
                </span>

                <span
                  :if={@bonus_secondary == stat}
                  class="ml-2 font-medium text-emerald-400"
                >
                  Bonus racial +1
                </span>
              </p>
            </div>

            <div class="flex items-center gap-3">
              <button
                type="button"
                id={"decrement-#{stat}"}
                phx-click="decrement_stat"
                phx-value-stat={stat}
                disabled={@base_scores[stat] <= @min_stat}
                aria-label={"Diminuer #{stat_label(stat)}"}
                class="flex h-9 w-9 items-center justify-center rounded-lg border border-zinc-600 text-lg text-zinc-200 transition hover:border-amber-400 hover:text-amber-300 disabled:cursor-not-allowed disabled:opacity-30"
              >
                −
              </button>

              <div class="flex min-w-16 flex-col items-center rounded-lg bg-zinc-900 px-3 py-2">
                <span class="text-2xl font-bold text-white">
                  {final_score(assigns, stat)}
                </span>

                <span class="mt-1 text-xs uppercase tracking-wide text-zinc-500">
                  Score
                </span>

                <span class="mt-1 text-sm font-bold text-amber-400">
                  {ability_modifier_label(final_score(assigns, stat))}
                </span>

                <span class="text-[10px] uppercase tracking-wide text-zinc-500">
                  Modificateur
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
                class="flex h-9 w-9 items-center justify-center rounded-lg border border-zinc-600 text-lg text-zinc-200 transition hover:border-amber-400 hover:text-amber-300 disabled:cursor-not-allowed disabled:opacity-30"
              >
                +
              </button>
            </div>

            <input
              type="hidden"
              name={"character[#{stat}]"}
              value={final_score(assigns, stat)}
            />
          </div>

          <div class="mt-4 grid gap-2 border-t border-zinc-800 pt-3 sm:grid-cols-2">
            <label class="flex cursor-pointer items-center gap-3 rounded-lg border border-zinc-800 px-3 py-2 transition hover:border-amber-500/50">
              <input
                type="checkbox"
                id={"bonus-primary-#{stat}"}
                checked={@bonus_primary == stat}
                phx-click="toggle_bonus"
                phx-value-bonus="primary"
                phx-value-stat={stat}
                class="h-4 w-4 rounded border-zinc-600 bg-zinc-900 text-amber-500 focus:ring-amber-500"
              />

              <span class="text-sm text-zinc-300">
                Bonus racial <strong class="text-amber-400">+3</strong>
              </span>
            </label>

            <label class={[
              "flex items-center gap-3 rounded-lg border border-zinc-800 px-3 py-2 transition",
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
                class="h-4 w-4 rounded border-zinc-600 bg-zinc-900 text-emerald-500 focus:ring-emerald-500 disabled:cursor-not-allowed"
              />

              <span class="text-sm text-zinc-300">
                Bonus racial <strong class="text-emerald-400">+1</strong>
              </span>
            </label>
          </div>
        </div>
      </div>

      <div class="mt-5 rounded-xl border border-zinc-800 bg-zinc-950/40 p-4 text-sm text-zinc-400">
        <p>
          Les valeurs de base vont de <strong class="text-zinc-200">{@min_stat} à {@max_stat}</strong>.
        </p>
        <p class="mt-1">
          Une caractéristique peut atteindre <strong class="text-zinc-200">{@max_stat + 3}</strong>
          grâce au bonus racial de +3.
        </p>
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

  defp stat_label(:strength), do: "Force"
  defp stat_label(:dexterity), do: "Dextérité"
  defp stat_label(:constitution), do: "Constitution"
  defp stat_label(:intelligence), do: "Intelligence"
  defp stat_label(:wisdom), do: "Sagesse"
  defp stat_label(:charisma), do: "Charisme"
end
