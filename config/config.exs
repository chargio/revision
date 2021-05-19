# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :revision,
  ecto_repos: [Revision.Repo]

config :revision_web,
  ecto_repos: [Revision.Repo],
  generators: [context_app: :revision]

# Configures the endpoint
config :revision_web, RevisionWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "m3UGw+mJMcjHVtUwNm8XYTqg64W0lLnFJn3VjdTpjBkyRcLs99CSgKhIKoOyOV7b",
  render_errors: [view: RevisionWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Revision.PubSub,
  live_view: [signing_salt: "mJJDqbkm"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
