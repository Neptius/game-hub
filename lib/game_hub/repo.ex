defmodule GameHub.Repo do
  use Ecto.Repo,
    otp_app: :game_hub,
    adapter: Ecto.Adapters.Postgres
end
