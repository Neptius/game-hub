defmodule GameHubWeb.Bg3Live.Show do
  use GameHubWeb, :live_view

  alias GameHub.Bg3

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    character = Bg3.get_character!(id)

    {:ok, assign(socket, :character, character)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      current_scope={@current_scope}
      game={GameHub.Games.get!("bg3")}
      active={:characters}
    >
      <div class="mx-auto max-w-4xl px-4 py-10">
        <div class="mb-8 flex items-center justify-between">
          <div>
            <p class="hud-mono hud-glow text-xs">&gt; character_sheet</p>
            <h1 class="hud-display mt-2 text-5xl">{@character.name}</h1>
          </div>

          <div class="flex gap-3">
            <.link
              navigate={~p"/bg3/characters/#{@character.id}/edit"}
              class="hud-mono border border-(--accent)/40 px-4 py-2 text-xs font-medium text-zinc-100 transition hover:bg-(--accent)/15"
            >
              Modifier
            </.link>

            <.link
              navigate={~p"/bg3/characters"}
              class="hud-btn hud-mono"
            >
              Retour
            </.link>
          </div>
        </div>

        <div class="grid gap-6 lg:grid-cols-2">
          <div class="hud-panel p-6">
            <h2 class="mb-4 text-xl font-semibold text-white">Identité</h2>
            <dl class="space-y-3 text-sm text-zinc-300">
              <div class="flex justify-between gap-4">
                <dt class="text-zinc-500">Race</dt>
                <dd>{@character.race}</dd>
              </div>
              <div :if={@character.subrace} class="flex justify-between gap-4">
                <dt class="text-zinc-500">Sous-race</dt>
                <dd>{@character.subrace}</dd>
              </div>
              <div class="flex justify-between gap-4">
                <dt class="text-zinc-500">Classe</dt>
                <dd>{@character.class}</dd>
              </div>
              <div :if={@character.subclass} class="flex justify-between gap-4">
                <dt class="text-zinc-500">Sous-classe</dt>
                <dd>{@character.subclass}</dd>
              </div>
              <div class="flex justify-between gap-4">
                <dt class="text-zinc-500">Historique</dt>
                <dd>{@character.background}</dd>
              </div>
              <div :if={@character.alignment} class="flex justify-between gap-4">
                <dt class="text-zinc-500">Alignement</dt>
                <dd>{@character.alignment}</dd>
              </div>
            </dl>
          </div>

          <div class="hud-panel p-6">
            <h2 class="mb-4 text-xl font-semibold text-white">Caractéristiques</h2>
            <dl class="grid grid-cols-1 gap-1.5 text-sm text-zinc-300">
              <div class="flex items-center justify-between gap-3 border-l-2 border-(--accent)/40 bg-black/40 px-3 py-1.5">
                <dt class="text-zinc-500">Force</dt>
                <dd class="flex items-baseline gap-2">
                  <span class="font-semibold text-white">
                    {@character.strength}
                  </span>

                  <span class="text-xs font-bold text-(--accent)">
                    {ability_modifier_label(@character.strength)}
                  </span>
                </dd>
              </div>
              <div class="flex items-center justify-between gap-3 border-l-2 border-(--accent)/40 bg-black/40 px-3 py-1.5">
                <dt class="text-zinc-500">Dextérité</dt>
                <dd class="flex items-baseline gap-2">
                  <span class="font-semibold text-white">
                    {@character.dexterity}
                  </span>

                  <span class="text-xs font-bold text-(--accent)">
                    {ability_modifier_label(@character.dexterity)}
                  </span>
                </dd>
              </div>
              <div class="flex items-center justify-between gap-3 border-l-2 border-(--accent)/40 bg-black/40 px-3 py-1.5">
                <dt class="text-zinc-500">Constitution</dt>
                <dd class="flex items-baseline gap-2">
                  <span class="font-semibold text-white">
                    {@character.constitution}
                  </span>

                  <span class="text-xs font-bold text-(--accent)">
                    {ability_modifier_label(@character.constitution)}
                  </span>
                </dd>
              </div>
              <div class="flex items-center justify-between gap-3 border-l-2 border-(--accent)/40 bg-black/40 px-3 py-1.5">
                <dt class="text-zinc-500">Intelligence</dt>
                <dd class="flex items-baseline gap-2">
                  <span class="font-semibold text-white">
                    {@character.intelligence}
                  </span>

                  <span class="text-xs font-bold text-(--accent)">
                    {ability_modifier_label(@character.intelligence)}
                  </span>
                </dd>
              </div>
              <div class="flex items-center justify-between gap-3 border-l-2 border-(--accent)/40 bg-black/40 px-3 py-1.5">
                <dt class="text-zinc-500">Sagesse</dt>
                <dd class="flex items-baseline gap-2">
                  <span class="font-semibold text-white">
                    {@character.wisdom}
                  </span>

                  <span class="text-xs font-bold text-(--accent)">
                    {ability_modifier_label(@character.wisdom)}
                  </span>
                </dd>
              </div>
              <div class="flex items-center justify-between gap-3 border-l-2 border-(--accent)/40 bg-black/40 px-3 py-1.5">
                <dt class="text-zinc-500">Charisme</dt>
                <dd class="flex items-baseline gap-2">
                  <span class="font-semibold text-white">
                    {@character.charisma}
                  </span>

                  <span class="text-xs font-bold text-(--accent)">
                    {ability_modifier_label(@character.charisma)}
                  </span>
                </dd>
              </div>
            </dl>
          </div>
        </div>

        <div :if={@character.notes} class="mt-6 hud-panel p-6">
          <h2 class="mb-3 text-xl font-semibold text-white">Notes</h2>
          <p class="whitespace-pre-wrap text-zinc-300">{@character.notes}</p>
        </div>
      </div>
    </Layouts.app>
    """
  end

  defp ability_modifier(score) when is_integer(score) do
    Integer.floor_div(score - 10, 2)
  end

  defp ability_modifier_label(score) do
    modifier = ability_modifier(score)

    if modifier >= 0 do
      "+#{modifier}"
    else
      Integer.to_string(modifier)
    end
  end
end
