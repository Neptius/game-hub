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
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-4xl px-4 py-10">
        <div class="mb-8 flex items-center justify-between">
          <div>
            <p class="text-sm uppercase tracking-[0.2em] text-zinc-400">Baldur's Gate 3</p>
            <h1 class="mt-2 text-3xl font-bold text-zinc-100">{@character.name}</h1>
          </div>

          <div class="flex gap-3">
            <.link
              navigate={~p"/baldurs-gate-3/characters/#{@character.id}/edit"}
              class="rounded-xl border border-zinc-700 px-4 py-2 text-sm font-medium text-zinc-100 hover:border-zinc-500"
            >
              Modifier
            </.link>

            <.link
              navigate={~p"/baldurs-gate-3/characters"}
              class="rounded-xl bg-amber-500 px-4 py-2 text-sm font-semibold text-zinc-950 hover:bg-amber-400"
            >
              Retour
            </.link>
          </div>
        </div>

        <div class="grid gap-6 lg:grid-cols-2">
          <div class="rounded-2xl border border-zinc-800 bg-zinc-900/70 p-6">
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

          <div class="rounded-2xl border border-zinc-800 bg-zinc-900/70 p-6">
            <h2 class="mb-4 text-xl font-semibold text-white">Caractéristiques</h2>
            <dl class="grid grid-cols-2 gap-4 text-sm text-zinc-300">
              <div class="rounded-xl bg-zinc-950/60 p-3"><dt class="text-zinc-500">Force</dt><dd class="mt-1 text-lg text-white">{@character.strength}</dd></div>
              <div class="rounded-xl bg-zinc-950/60 p-3"><dt class="text-zinc-500">Dextérité</dt><dd class="mt-1 text-lg text-white">{@character.dexterity}</dd></div>
              <div class="rounded-xl bg-zinc-950/60 p-3"><dt class="text-zinc-500">Constitution</dt><dd class="mt-1 text-lg text-white">{@character.constitution}</dd></div>
              <div class="rounded-xl bg-zinc-950/60 p-3"><dt class="text-zinc-500">Intelligence</dt><dd class="mt-1 text-lg text-white">{@character.intelligence}</dd></div>
              <div class="rounded-xl bg-zinc-950/60 p-3"><dt class="text-zinc-500">Sagesse</dt><dd class="mt-1 text-lg text-white">{@character.wisdom}</dd></div>
              <div class="rounded-xl bg-zinc-950/60 p-3"><dt class="text-zinc-500">Charisme</dt><dd class="mt-1 text-lg text-white">{@character.charisma}</dd></div>
            </dl>
          </div>
        </div>

        <div :if={@character.notes} class="mt-6 rounded-2xl border border-zinc-800 bg-zinc-900/70 p-6">
          <h2 class="mb-3 text-xl font-semibold text-white">Notes</h2>
          <p class="whitespace-pre-wrap text-zinc-300">{@character.notes}</p>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
