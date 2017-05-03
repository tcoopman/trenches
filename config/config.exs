# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :trenches, Trenches.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "kw62tH5dy3RVgvORwglwuedRTI/v17iPjVsb42dwOHTRzR+8eHO2Kglba8dP6Xci",
  render_errors: [view: Trenches.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Trenches.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
