# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :tzdata, :autoupdate, :disabled
# Configures the endpoint
config :myFitnessSnapChatMessage, MyFitnessSnapChatMessageWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "lfBZL/fTeBxkJBWlFtVV9FYjU24w0k3XmyU2QjUlioi1AV9OWZwLkDQ3kOX+sd0v",
  render_errors: [view: MyFitnessSnapChatMessageWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: MyFitnessSnapChatMessage.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
