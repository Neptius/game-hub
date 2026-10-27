defmodule GameHubWeb.HubLive.Index do
  use GameHubWeb, :live_view

  alias GameHub.Games

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:page_title, "Choisir un jeu") |> assign(:games, Games.list())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-6xl px-4 py-16 sm:px-6">
        <div class="hud-rise mb-14">
          <p class="hud-mono hud-glow text-xs">&gt; select_game --player-one</p>
          <h1 class="hud-display mt-4 text-5xl sm:text-7xl">
            Choose your <span class="hud-glow">game</span>
          </h1>
          <p class="mt-4 max-w-xl text-zinc-400">
            Un hub, plusieurs univers. Sélectionne un jeu pour ouvrir son poste de commande.
          </p>
        </div>

        <div id="games" class="grid gap-8 md:grid-cols-2">
          <.link
            :for={{game, i} <- Enum.with_index(@games)}
            id={"game-#{game.slug}"}
            navigate={"/#{game.slug}"}
            style={"--accent: #{game.accent}; --accent-alt: #{game.accent_alt}; animation-delay: #{i * 120}ms;"}
            class="hud-panel hud-rise group block overflow-hidden p-8"
          >
            <div
              class="absolute inset-0 opacity-50 transition duration-500 group-hover:opacity-100"
              style={"background: radial-gradient(70% 90% at 100% 0%, #{game.accent}40, transparent 65%), linear-gradient(160deg, transparent 40%, #{game.accent_alt}55);"}
            />
            <span class="hud-display pointer-events-none absolute -bottom-6 -right-2 select-none text-[9rem] leading-none text-(--accent)/10 transition group-hover:text-(--accent)/20">
              {game.short_name}
            </span>

            <div class="relative">
              <div class="flex items-center justify-between">
                <span class="hud-mono hud-tag">{if Games.available?(game), do: "online", else: "soon"}</span>
                <span class="hud-mono text-[0.65rem] text-zinc-500">
                  {String.pad_leading(Integer.to_string(i + 1), 2, "0")}
                </span>
              </div>
              <.icon name={game.icon} class="hud-glow mt-8 size-14" />
              <h2 class="hud-display mt-4 text-4xl">{game.name}</h2>
              <p class="mt-2 max-w-sm text-sm text-zinc-400">{game.tagline}</p>

              <ul class="mt-6 space-y-1.5">
                <li
                  :for={feature <- game.features}
                  class="hud-mono flex items-center gap-2 text-[0.65rem] text-zinc-300"
                >
                  <span class={[
                    "size-1.5 rotate-45",
                    if(feature.path, do: "bg-(--accent)", else: "bg-zinc-600")
                  ]}></span>
                  {feature.name}
                </li>
              </ul>

              <p class="hud-mono hud-glow mt-8 flex items-center gap-2 text-xs font-bold">
                Enter
                <.icon
                  name="lucide:chevrons-right"
                  class="size-4 transition group-hover:translate-x-2"
                />
              </p>
            </div>
          </.link>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
