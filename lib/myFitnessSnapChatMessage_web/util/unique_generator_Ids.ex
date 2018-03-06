defmodule MyFitnessSnapChatMessage.UniqueGeneratorIDS do
  def start_link do
    Agent.start_link(fn -> 1 end, name: __MODULE__)
  end

  def nextId do
    Agent.get_and_update(__MODULE__, fn state -> {state, state + 1} end)
  end
end
