import Config

# Configure your database
config :game_hub, GameHub.Repo,
  username: "postgres",
  password: "pass",
  hostname: "localhost",
  database: "game_hub_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
