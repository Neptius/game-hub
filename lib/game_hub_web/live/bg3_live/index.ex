defmodule GameHubWeb.Bg3Live.Index do
  use GameHubWeb, :live_view

  alias GameHub.Bg3

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :characters, Bg3.list_characters())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    character = Bg3.get_character!(id)
    {:ok, _} = Bg3.delete_character(character)

    {:noreply, assign(socket, :characters, Bg3.list_characters())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-6xl px-4 py-10">
        <div class="mb-8 flex items-center justify-between gap-4">
          <div>
            <p class="text-sm uppercase tracking-[0.2em] text-zinc-400">Baldur's Gate 3</p>
            <h1 class="mt-2 text-3xl font-bold text-zinc-100">Character Builder</h1>
          </div>

          <.link
            navigate={~p"/baldurs-gate-3/characters/new"}
            class="inline-flex items-center rounded-xl bg-amber-500 px-4 py-2 text-sm font-semibold text-zinc-950 shadow-lg shadow-amber-500/20 transition hover:bg-amber-400"
          >
            + Nouveau build
          </.link>
        </div>

        <div :if={Enum.empty?(@characters)} class="rounded-2xl border border-zinc-800 bg-zinc-900/50 p-10 text-center">
          <p class="text-lg text-zinc-300">Aucun personnage sauvegardé pour le moment.</p>
          <.link
            navigate={~p"/baldurs-gate-3/characters/new"}
            class="mt-4 inline-block text-amber-400 underline"
          >
            Créer votre premier build
          </.link>
        </div>

        <div :if={!Enum.empty?(@characters)} class="grid gap-5 md:grid-cols-2 xl:grid-cols-3">
          <div
            :for={character <- @characters}
            id={"character-#{character.id}"}
            class="rounded-2xl border border-zinc-800 bg-zinc-900/70 p-5 shadow-xl shadow-zinc-950/20"
          >
            <div class="flex items-start justify-between gap-3">
              <div>
                <p class="text-xl font-semibold text-white">{character.name}</p>
                <p class="mt-1 text-sm text-zinc-400">
                  {character.race}
                  <span :if={character.subrace}> • {character.subrace}</span>
                </p>
              </div>

              <button
                type="button"
                phx-click="delete"
                phx-value-id={character.id}
                class="rounded-lg border border-red-500/40 px-2 py-1 text-xs font-medium text-red-300 transition hover:bg-red-500/10"
              >
                Supprimer
              </button>
            </div>

            <div class="mt-4 space-y-2 text-sm text-zinc-300">
              <p><span class="text-zinc-500">Classe :</span> {character.class}</p>
              <p :if={character.subclass}><span class="text-zinc-500">Sous-classe :</span> {character.subclass}</p>
              <p><span class="text-zinc-500">Historique :</span> {character.background}</p>
            </div>

            <div class="mt-5 flex gap-3">
              <.link
                navigate={~p"/baldurs-gate-3/characters/#{character.id}"}
                class="text-sm font-medium text-amber-400 hover:underline"
              >
                Voir
              </.link>

              <.link
                navigate={~p"/baldurs-gate-3/characters/#{character.id}/edit"}
                class="text-sm font-medium text-zinc-300 hover:underline"
              >
                Modifier
              </.link>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
