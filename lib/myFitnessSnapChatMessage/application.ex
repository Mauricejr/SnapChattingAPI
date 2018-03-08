defmodule MyFitnessSnapChatMessage.Application do
  alias MyFitnessSnapChatMessage.Util.MessageJasonValidator
  alias MyFitnessSnapChatMessage.CacheMessageActions
  use Application

  @moduledoc """
  This module supperviser workers and supervisor
  """

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      worker(Cachex, [:disk_message_cache, []]),
      worker(MessageJasonValidator, [[]]),
      worker(CacheMessageActions, [[]]),
      supervisor(MyFitnessSnapChatMessageWeb.Endpoint, []),
      supervisor(MyFitnessSnapChatMessage.CacheSupervisor, []),
      supervisor(ConCache, [[], [name: :message_cache]])
    ]

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
