defmodule MyFitnessSnapChatMessage.CacheMessages do
  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def put(key, value) do
    Agent.update(__MODULE__, fn state ->
      case Map.has_key?(state, key) do
        false ->
          Map.put(state, key, [value])
        _ ->
          listofIds = state[key]
          %{state | key => [value | listofIds]}
      end
    end)
  end

  def get(key) do
    Agent.get(__MODULE__, fn state ->
      case Map.has_key?(state, key) do
        nil ->
          {:error}
        _ ->
          if(state[key] == nil) do
            {:error}
          else
            {:ok, state[key]}
          end
      end
    end)
  end

  def dropId(key, id_to_delete) do
    Agent.update(__MODULE__, fn state ->
      case Map.has_key?(state, key) do
        false ->
          state
        _ ->
          ids_to_delete = state[key]
          update_keys = List.delete(ids_to_delete, id_to_delete)
          Map.replace!(state, key, update_keys)
      end
    end)
  end
end
