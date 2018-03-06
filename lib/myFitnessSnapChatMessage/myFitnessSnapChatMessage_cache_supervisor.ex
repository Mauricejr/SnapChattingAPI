defmodule MyFitnessSnapChatMessage.CacheSupervisor do
alias MyFitnessSnapChatMessage.CacheMessages
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
  #{ :ok, true } = Cachex.dump(:my_cache, "/lib/database_dump")
  children = [
    worker(CacheMessages, [])
  ]
supervise(children, strategy: :one_for_one)
end
end
