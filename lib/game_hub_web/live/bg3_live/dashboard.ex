defmodule GameHubWeb.Bg3Live.Dashboard do
  use GameHubWeb, :live_view

  alias GameHub.{Bg3, Games}

  @impl true
  def mount(_params, _session, socket) do
    characters = Bg3.list_characters()

    {:ok,
     socket
     |> assign(:page_title, "Baldur's Gate 3")
     |> assign(:game, Games.get!("bg3"))
     |> assign(:character_count, length(characters))
     |> assign(:recent, Enum.take(characters, 4))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} game={@game}>
      <.game_dashboard game={@game}>
        <:actions>
          <.link
            id="new-build"
            navigate={~p"/bg3/characters/new"}
            class="hud-btn hud-mono"
          >
            <.icon name="lucide:sword" class="size-5" /> Nouveau build
          </.link>
        </:actions>

        <div class="mt-8 grid gap-4 sm:grid-cols-3">
          <.stat
            label="Builds sauvegardés"
            value={@character_count}
            percent={min(@character_count * 10, 100)}
          />
          <.stat icon="lucide:trophy" label="Niveau max" value="12" />
          <.stat icon="lucide:wand-sparkles" label="Classes" value="12" />
        </div>

        <div :if={@recent != []} id="recent-builds">
          <.section_title>Builds récents</.section_title>
          <div class="grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
            <.link
              :for={character <- @recent}
              id={"recent-#{character.id}"}
              navigate={~p"/bg3/characters/#{character.id}"}
              class="hud-panel block p-4"
              style="--cut: 12px;"
            >
              <p class="hud-mono text-sm font-bold">{character.name}</p>
              <p class="mt-2 text-xs text-zinc-400">{character.race} · {character.class}</p>
            </.link>
          </div>
        </div>
      </.game_dashboard>
    </Layouts.app>
    """
  end
end
