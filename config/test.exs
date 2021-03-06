use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :go_links, GoLinks.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :go_links, GoLinks.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "jduan",
  password: "jduan",
  database: "go_links_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
