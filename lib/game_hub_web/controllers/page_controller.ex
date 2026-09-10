defmodule GameHubWeb.PageController do
  use GameHubWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
