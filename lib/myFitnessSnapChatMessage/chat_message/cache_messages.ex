defmodule MyFitnessSnapChatMessage.CacheMessages do
  @moduledoc """
  This module keeps username and ids in map using Agent
  example:
  %{"username" =>[ids]}
  """
  @doc """
  Start and link proccess
  """
  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  @doc """
  store username and  or add new  id to existing user in a map
  ## Parameters
  """
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

  @doc """
   Use username(key) to get all ids for a user
  """
  def get(key) do
    Agent.get(__MODULE__, fn state ->
      case Map.has_key?(state, key) do
        false ->
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

  @doc """
       Remove Id for a given key(username)
  """
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
