defmodule GameHubWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use GameHubWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://phoenix.hexdocs.pm/scopes.html)"

  attr :game, :any, default: nil, doc: "the `GameHub.Games.Game` currently displayed, if any"

  attr :active, :atom,
    default: nil,
    doc: "the id of the active game feature in the sub navigation"

  slot :inner_block, required: true

  def app(assigns) do
    assigns =
      assigns
      |> assign(:accent, if(assigns.game, do: assigns.game.accent, else: "#fcee0a"))
      |> assign(:accent_alt, if(assigns.game, do: assigns.game.accent_alt, else: "#ff2a6d"))

    ~H"""
    <div
      id="app-shell"
      data-theme="dark"
      style={"--accent: #{@accent}; --accent-alt: #{@accent_alt};"}
      class="hud-root min-h-screen text-zinc-100"
    >
      <div class="hud-mono sticky top-0 z-30 flex items-center gap-3 border-b border-(--accent)/20 bg-black/60 px-4 py-3 backdrop-blur-md lg:hidden">
        <button
          type="button"
          id="sidebar-open"
          aria-label="Ouvrir le menu"
          phx-click={JS.set_attribute({"data-open", "true"}, to: "#sidebar")}
          class="flex size-9 items-center justify-center border border-(--accent)/40 text-(--accent)"
        >
          <.icon name="lucide:menu" class="size-5" />
        </button>
        <span class="text-sm font-bold text-white">
          Game<span class="hud-glow">Hub</span>
          <span :if={@game} class="hud-glow ml-2">// {@game.short_name}</span>
        </span>
      </div>

      <div
        id="sidebar-backdrop"
        class="hud-side-backdrop"
        phx-click={JS.remove_attribute("data-open", to: "#sidebar")}
      />

      <aside id="sidebar" class="hud-side z-40 flex flex-col">
        <div class="hud-side-head px-5 py-6">
          <div class="flex items-center justify-between gap-2">
            <.link
              navigate={~p"/"}
              id="nav-hub"
              class="hud-mono flex items-center gap-2 text-sm font-bold text-white"
            >
              <span class="hud-dot"></span>
              <span class="hud-label">Game<span class="hud-glow">Hub</span></span>
            </.link>
            <button
              type="button"
              id="sidebar-close"
              aria-label="Fermer le menu"
              phx-click={JS.remove_attribute("data-open", to: "#sidebar")}
              class="text-zinc-400 hover:text-white lg:hidden"
            >
              <.icon name="lucide:x" class="size-5" />
            </button>
          </div>

          <.link
            :if={@game}
            navigate={"/#{@game.slug}"}
            id="nav-game"
            class="hud-display hud-glow mt-6 block text-2xl"
          >
            <.icon name={@game.icon} class="hud-collapsed-only size-8" />
            <span class="hud-label flex items-center gap-3">
              <.icon name={@game.icon} class="size-8" /> {@game.short_name}
            </span>
          </.link>
        </div>

        <nav id="game-nav" class="hud-mono flex flex-1 flex-col gap-1 overflow-y-auto">
          <%= if @game do %>
            <.side_link navigate={"/#{@game.slug}"} icon="lucide:castle" current={is_nil(@active)}>
              Dashboard
            </.side_link>
            <%= for feature <- @game.features do %>
              <.side_link
                navigate={feature.path}
                icon={feature.icon}
                current={@active == feature.id}
                disabled={is_nil(feature.path)}
              >
                {feature.name}
              </.side_link>
            <% end %>
          <% else %>
            <.side_link navigate={~p"/"} icon="lucide:dices" current>Jeux</.side_link>
          <% end %>
        </nav>

        <div class="hud-mono border-t border-(--accent)/15 p-4 text-[0.65rem] text-zinc-400">
          <ul class="hud-label space-y-3 px-1">
            <%= if @current_scope do %>
              <li class="truncate normal-case tracking-normal text-zinc-500">
                {@current_scope.user.email}
              </li>
              <li><.link href={~p"/users/settings"} class="hover:text-white">Settings</.link></li>
              <li>
                <.link href={~p"/users/log-out"} method="delete" class="hover:text-white">
                  Log out
                </.link>
              </li>
            <% else %>
              <li><.link href={~p"/users/log-in"} class="hud-tag">Log in</.link></li>
              <li><.link href={~p"/users/register"} class="hover:text-white">Register</.link></li>
            <% end %>
          </ul>
          <button
            type="button"
            id="sidebar-toggle"
            aria-label="Réduire ou agrandir le menu"
            phx-click={JS.dispatch("phx:toggle-sidebar")}
            class="hud-collapse-btn mt-4 hidden w-full items-center gap-3 px-1 py-2 text-zinc-500 transition hover:text-white lg:flex"
          >
            <.icon name="lucide:chevrons-left" class="hud-chevron size-4 transition" />
            <span class="hud-label">Réduire</span>
          </button>
        </div>
      </aside>

      <main class="hud-main relative z-10">
        {render_slot(@inner_block)}
      </main>

      <.flash_group flash={@flash} />
    </div>
    """
  end

  attr :navigate, :string, default: nil
  attr :icon, :string, required: true
  attr :current, :boolean, default: false
  attr :disabled, :boolean, default: false
  slot :inner_block, required: true

  defp side_link(assigns) do
    ~H"""
    <%= if @disabled do %>
      <span
        title={render_slot(@inner_block)}
        class="flex items-center gap-3 whitespace-nowrap px-6 py-2.5 text-[0.7rem] text-zinc-600"
      >
        <.icon name={@icon} class="size-4 shrink-0" />
        <span class="hud-label">{render_slot(@inner_block)}</span>
        <span class="hud-label ml-auto text-[0.55rem]">locked</span>
      </span>
    <% else %>
      <.link
        navigate={@navigate}
        title={render_slot(@inner_block)}
        aria-current={if(@current, do: "page")}
        class={[
          "flex items-center gap-3 whitespace-nowrap border-l-2 px-5 py-2.5 text-[0.7rem] transition",
          if(@current,
            do:
              "border-(--accent) bg-(--accent)/10 text-white shadow-[inset_12px_0_24px_-16px_var(--accent)]",
            else: "border-transparent text-zinc-400 hover:border-(--accent)/50 hover:text-white"
          )
        ]}
      >
        <.icon name={@icon} class="size-4 shrink-0" />
        <span class="hud-label">{render_slot(@inner_block)}</span>
      </.link>
    <% end %>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={
          show(".phx-client-error #client-error")
          |> JS.remove_attribute("hidden", to: ".phx-client-error #client-error")
        }
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="lucide:loader-circle" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={
          show(".phx-server-error #server-error")
          |> JS.remove_attribute("hidden", to: ".phx-server-error #server-error")
        }
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="lucide:loader-circle" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border border-base-200 bg-base-100 brightness-200 left-0 in-data-[theme=light]:left-1/3 in-data-[theme=dark]:left-2/3 in-data-[theme-source=system]:left-0! transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="lucide:monitor" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="lucide:sun" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="lucide:moon" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
