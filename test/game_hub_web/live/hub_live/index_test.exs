defmodule GameHubWeb.HubLive.IndexTest do
  use GameHubWeb.ConnCase

  import Phoenix.LiveViewTest

  test "lists games on the root page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    assert has_element?(view, "#game-bg3")
    assert has_element?(view, "#game-dota2")
  end

  test "bg3 dashboard links to the character builder", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/bg3")
    assert has_element?(view, "#dashboard-bg3")
    assert has_element?(view, "#feature-characters")
    assert has_element?(view, "#new-build")
  end

  test "coming-soon game dashboard renders", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/dota2")
    assert has_element?(view, "#dashboard-dota2")
  end

  test "unknown game redirects home", %{conn: conn} do
    assert {:error, {:live_redirect, %{to: "/"}}} = live(conn, "/nope")
  end
end
