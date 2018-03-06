defmodule MyFitnessSnapChatMessage.Application do
  alias MyFitnessSnapChatMessage.UniqueGeneratorIDS
  alias MyFitnessSnapChatMessage.Util.MessageJasonValidator
  alias MyFitnessSnapChatMessage.CacheMessageActions
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
     worker(UniqueGeneratorIDS,[]),
     worker(Cachex, [:disk_message_cache, []]),
     worker(MessageJasonValidator, [[]]),
     worker(CacheMessageActions, [[]]),
      # Start the Ecto repository
      #supervisor(MyFitnessSnapChatMessage.Repo, []),
      # Start the endpoint when the application starts
      supervisor(MyFitnessSnapChatMessageWeb.Endpoint, []),
      supervisor(MyFitnessSnapChatMessage.CacheSupervisor, []),
      supervisor(ConCache, [[], [name: :message_cache]]),
      # Start your own worker by calling: FitnessPalCodingExercise.Worker.start_link(arg1, arg2, arg3)
      # worker(FitnessPalCodingExercise.Worker, [arg1, arg2, arg3]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MyFitnessSnapChatMessage.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MyFitnessSnapChatMessageWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
