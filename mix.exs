defmodule MyFitnessSnapChatMessage.Mixfile do
  use Mix.Project

  def project do
    [
      app: :myFitnessSnapChatMessage,
      version: "0.0.1",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {MyFitnessSnapChatMessage.Application, []},
      extra_applications: [:logger, :runtime_tools,:runtime_tools,:con_cache,:cachex,:distillery,:snowflake]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]


  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.

  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
        {:phoenix_pubsub, "~> 1.0"},
        {:postgrex, ">= 0.0.0"},
        {:cowboy, "~> 1.0"},
        {:timex, "~> 3.1"},
        {:gettext, "~> 0.15.0"},
        {:poison,  "~> 3.1"},
        {:con_cache, "~> 0.12.1"},
        {:batch, "~> 0.2"},
        {:async_with, "~> 0.3"},
        {:cachex, "~> 3.0"},
        {:ex_json_schema, "~> 0.5.4"},
        {:exactor, "~> 2.2.4", warn_missing: false},
        {:distillery, "~> 1.0.0"},
        {:libcluster, "~> 2.0.3"},
        {:snowflake, "~> 1.0.0"}

    ]
  end
end
