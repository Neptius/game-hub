defmodule GameHubWeb.GameComponents do
  @moduledoc "Reusable building blocks for per-game dashboards."
  use Phoenix.Component
  import GameHubWeb.CoreComponents, only: [icon: 1]

  attr :game, :any, required: true
  slot :actions
  slot :inner_block

  def game_dashboard(assigns) do
    ~H"""
    <div id={"dashboard-#{@game.slug}"} class="mx-auto max-w-6xl px-4 py-12 sm:px-6">
      <.game_hero game={@game}>
        <:actions>{render_slot(@actions)}</:actions>
      </.game_hero>

      {render_slot(@inner_block)}

      <.section_title>Modules</.section_title>
      <.feature_grid features={@game.features} />
    </div>
    """
  end

  slot :inner_block, required: true

  def section_title(assigns) do
    ~H"""
    <div class="mb-5 mt-14 flex items-center gap-4">
      <h2 class="hud-mono hud-glow text-xs font-bold">// {render_slot(@inner_block)}</h2>
      <span class="h-px flex-1 bg-linear-to-r from-(--accent)/50 to-transparent"></span>
    </div>
    """
  end

  attr :game, :any, required: true
  slot :actions

  def game_hero(assigns) do
    ~H"""
    <section class="hud-panel hud-rise overflow-hidden p-8 sm:p-14" style="--cut: 32px;">
      <div
        class="absolute inset-0"
        style={"background: radial-gradient(80% 120% at 100% 0%, #{@game.accent}55, transparent 60%), linear-gradient(120deg, #{@game.accent_alt}66, transparent 60%);"}
      />
      <span class="hud-display pointer-events-none absolute -right-4 -top-6 select-none text-[12rem] leading-none text-white/5">
        {@game.short_name}
      </span>
      <div class="relative">
        <p class="hud-mono hud-glow flex items-center gap-2 text-xs">
          <span class="hud-dot"></span> system online
        </p>
        <div class="mt-4 flex items-center gap-5">
          <.icon name={@game.icon} class="hud-glow hidden size-16 sm:block" />
          <h1 class="hud-display text-5xl sm:text-7xl">{@game.name}</h1>
        </div>
        <p class="mt-4 max-w-xl text-zinc-300">{@game.tagline}</p>
        <div class="mt-8 flex flex-wrap gap-3">{render_slot(@actions)}</div>
      </div>
    </section>
    """
  end

  attr :features, :list, required: true

  def feature_grid(assigns) do
    ~H"""
    <div class="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
      <%= for {feature, i} <- Enum.with_index(@features, 1) do %>
        <%= if feature.path do %>
          <.link
            id={"feature-#{feature.id}"}
            navigate={feature.path}
            class="hud-panel group block p-6"
          >
            <.feature_body feature={feature} index={i} />
          </.link>
        <% else %>
          <div id={"feature-#{feature.id}"} class="hud-panel hud-panel-off p-6">
            <.feature_body feature={feature} index={i} soon />
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end

  attr :feature, :any, required: true
  attr :index, :integer, required: true
  attr :soon, :boolean, default: false

  defp feature_body(assigns) do
    ~H"""
    <div class="flex items-start justify-between">
      <span class="flex size-11 items-center justify-center border border-(--accent)/40 bg-(--accent)/10 text-(--accent)">
        <.icon name={@feature.icon} class="size-5" />
      </span>
      <span class="hud-mono text-[0.65rem] text-zinc-500">
        {if @soon, do: "locked", else: "0#{@index}"}
      </span>
    </div>
    <h3 class="hud-mono mt-5 text-sm font-bold text-white">{@feature.name}</h3>
    <p class="mt-2 text-sm text-zinc-400">{@feature.description}</p>
    """
  end

  attr :label, :string, required: true
  attr :value, :any, required: true
  attr :percent, :integer, default: 100
  attr :icon, :string, default: nil

  def stat(assigns) do
    ~H"""
    <div class="hud-panel p-5" style="--cut: 12px;">
      <div class="flex items-center justify-between">
        <p class="hud-mono text-[0.65rem] text-zinc-500">{@label}</p>
        <.icon :if={@icon} name={@icon} class="size-5 text-(--accent)/70" />
      </div>
      <p class="hud-display hud-glow mt-2 text-4xl">{@value}</p>
      <div class="hud-bar mt-3"><span style={"width: #{@percent}%"}></span></div>
    </div>
    """
  end
end
