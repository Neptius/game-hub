defmodule GameHubWeb.HubLive.Game do
  @moduledoc "Generic dashboard for games without a dedicated dashboard yet."
  use GameHubWeb, :live_view

  alias GameHub.Games

  @impl true
  def mount(%{"game" => slug}, _session, socket) do
    case Games.get(slug) do
      nil ->
        {:ok, socket |> put_flash(:error, "Jeu introuvable") |> push_navigate(to: ~p"/")}

      game ->
        {:ok, socket |> assign(:page_title, game.name) |> assign(:game, game)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} game={@game}>
      <.game_dashboard game={@game} />
    </Layouts.app>
    """
  end
end
