# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :cypto_bank,
  ecto_repos: [CyptoBank.Repo],
  generators: [binary_id: true]

# Add support for microseconds at the database level
# avoid having to configure it on every migration file
config :cypto_bank, CyptoBank.Repo, migration_timestamps: [type: :utc_datetime_usec]

# Configures the endpoint
config :cypto_bank, CyptoBankWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "vGiS/Yvos7ppc2tbPSNzzyEhQvp9oWYKOqUf65GcxU+4Flma6QaGJ2VDOqBBnMIR",
  render_errors: [view: CyptoBankWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: CyptoBank.PubSub,
  live_view: [signing_salt: "mSgdyJo6"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
