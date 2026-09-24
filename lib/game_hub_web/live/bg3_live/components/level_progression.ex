defmodule GameHubWeb.Bg3Live.Components.LevelProgression do
  @moduledoc """
  Composant d'affichage de la progression multiclasse par niveau.
  Extrait de `CharacterBuilder` pour garder ce dernier lisible.
  """

  use Phoenix.Component

  alias GameHub.Bg3.Reference
  alias GameHub.Bg3.Leveling

  defp subclass_disabled?(entry, progression) do
    case entry.class do
      nil ->
        true

      class ->
        class_occurrences =
          Enum.count(progression, fn level ->
            level.class == class
          end)

        class_occurrences >= 2
    end
  end

  defp can_add_level?(levels, max_level) do
    length(levels) < max_level and
      Leveling.ready_for_next_level?(levels)
  end

  defp class_passives_taken_elsewhere(progression, entry) do
    progression
    |> Enum.filter(&(&1.class == entry.class and &1.level != entry.level))
    |> Enum.flat_map(&(&1.class_passives || []))
  end

  attr :levels, :list, required: true
  attr :progression, :list, required: true
  attr :progression_errors, :list, required: true
  attr :max_level, :integer, required: true

  def level_progression(assigns) do
    ~H"""
    <div class="rounded-2xl border border-zinc-800 bg-zinc-900/70 p-6">
      <div class="mb-5 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h2 class="text-xl font-semibold text-white">Progression</h2>
          <p class="mt-1 text-sm text-zinc-400">
            Niveaux 1 à {@max_level}. Une classe conserve la même sous-classe sur toute la progression.
          </p>
        </div>

        <div class="flex gap-2">
          <button
            type="button"
            phx-click="remove_level"
            disabled={length(@levels) <= 1}
            class="rounded-lg border border-zinc-600 px-3 py-2 text-sm font-medium text-zinc-200 transition hover:border-amber-400 disabled:cursor-not-allowed disabled:opacity-30"
          >
            − Niveau
          </button>

          <button
            type="button"
            phx-click="add_level"
            disabled={!can_add_level?(@levels, @max_level)}
            class="rounded-lg border border-amber-500/40 bg-amber-500/10 px-3 py-2 text-sm font-medium text-amber-300 transition hover:bg-amber-500/20 disabled:cursor-not-allowed disabled:opacity-30"
          >
            + Niveau
          </button>
        </div>
      </div>

      <div
        :if={@progression_errors != []}
        class="mb-4 space-y-1 rounded-lg border border-red-500/40 bg-red-500/10 p-3"
      >
        <p :for={error <- @progression_errors} class="text-sm text-red-300">
          {error}
        </p>
      </div>

      <div class="space-y-3">
        <div
          :for={entry <- @progression}
          id={"level-#{entry.level}"}
          class="rounded-xl border border-zinc-700 bg-zinc-950/60 p-4"
        >
          <div class="grid gap-3 sm:grid-cols-[auto_1fr_1fr_auto] sm:items-end ">
            <div class="flex h-8 w-8 items-center justify-center rounded-lg bg-zinc-900 text-sm font-bold text-white">
              {entry.level}
            </div>

            <div>
              <label class="mb-1 block text-xs uppercase tracking-wide text-zinc-500">
                Classe
              </label>

              <select
                name={"level_class[#{entry.level}]"}
                phx-change="set_level_class"
                class="w-full rounded-lg border border-zinc-700 bg-zinc-900 px-3 py-2 text-sm text-zinc-100 focus:border-amber-400 focus:outline-none"
              >
                <option value="" selected={is_nil(entry.class)}>— Choisir —</option>
                <option
                  :for={class <- Reference.classes()}
                  value={class}
                  selected={entry.class == class}
                >
                  {class}
                </option>
              </select>
            </div>

            <div>
              <label class="mb-1 block text-xs uppercase tracking-wide text-zinc-500">
                Sous-classe
              </label>

              <select
                name={"level_subclass[#{entry.level}]"}
                phx-change="set_level_subclass"
                disabled={subclass_disabled?(entry, @progression)}
                class={[
                  "w-full rounded-lg border border-zinc-700 bg-zinc-900 px-3 py-2 text-sm text-zinc-100 focus:border-amber-400 focus:outline-none",
                  subclass_disabled?(entry, @progression) && "cursor-not-allowed opacity-50"
                ]}
              >
                <option value="" selected={is_nil(entry.subclass)}>
                  — Choisir —
                </option>

                <option
                  :for={subclass <- Reference.subclasses_for(entry.class)}
                  value={subclass}
                  selected={entry.subclass == subclass}
                >
                  {subclass}
                </option>
              </select>
            </div>
          </div>

          <div :if={entry.class_level} class="mt-3 pt-3 text-sm text-zinc-400">
            <span>
              Niveau <strong class="text-white">{entry.class_level}</strong> en {entry.class}
            </span>
          </div>

          <div :if={entry.feat_slot?} class="mt-3 border-t border-zinc-800 pt-3">
            <label class="mb-1 block text-xs uppercase tracking-wide text-amber-400">
              🏅 Don (niveau {entry.class_level} en {entry.class})
            </label>

            <input
              type="text"
              name={"level_feat[#{entry.level}]"}
              value={entry.feat}
              phx-blur="set_level_feat"
              placeholder="Ex: Combattant expérimenté, Athlète, Résilient..."
              class="w-full rounded-lg border border-zinc-700 bg-zinc-900 px-3 py-2 text-sm text-zinc-100 focus:border-amber-400 focus:outline-none"
            />
          </div>

          <div
            :if={entry.class_passive_slot?}
            class="mt-4 border-t border-zinc-800 pt-4"
          >
            <div class="mb-3 flex items-center justify-between gap-3">
              <div>
                <p class="text-xs font-semibold uppercase tracking-wide text-amber-400">
                  Passifs de classe
                </p>

                <p class="mt-1 text-xs text-zinc-500">
                  Choisissez 2 passifs pour le niveau {entry.class_level} de {entry.class}.
                </p>
              </div>

              <span class="text-xs text-zinc-400">
                {length(entry.class_passives || [])} / {Leveling.class_passives_per_slot()}
              </span>
            </div>

            <div class="grid gap-2 sm:grid-cols-2">
              <label
                :for={class_passive <- Reference.class_passives_for(entry.class)}
                class={[
                  "flex items-center gap-3 rounded-lg border px-3 py-2 transition",
                  class_passive in (entry.class_passives || []) &&
                    "cursor-pointer border-amber-400/70 bg-amber-500/10",
                  class_passive not in (entry.class_passives || []) &&
                    "cursor-pointer border-zinc-700 hover:border-zinc-500"
                ]}
              >
                <input
                  type="checkbox"
                  checked={class_passive in (entry.class_passives || [])}
                  phx-click="toggle_level_class_passive"
                  phx-value-level={entry.level}
                  phx-value-class_passive={class_passive}
                  disabled={
                    class_passive in class_passives_taken_elsewhere(@progression, entry) or
                      (length(entry.class_passives || []) >= Leveling.class_passives_per_slot() and
                         class_passive not in (entry.class_passives || []))
                  }
                  class="h-4 w-4 rounded border-zinc-600 bg-zinc-900 text-amber-500 focus:ring-amber-500 disabled:cursor-not-allowed disabled:opacity-40"
                />

                <span class="text-sm text-zinc-200">
                  {class_passive}
                </span>
              </label>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
