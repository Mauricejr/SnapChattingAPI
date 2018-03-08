defmodule MyFitnessSnapChatMessage.CacheMessageActions do
  alias MyFitnessSnapChatMessage.CacheMessages
  @path "./priv/database_dump/messages"
  require Logger
  use ExActor.GenServer

  @moduledoc """
  This module has methods to interact with in-memory cache and disk back cache
  """

  #@interval 50000
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_) do
  #  Process.send_after(self(), {:dumpMessage}, @interval)
    Cachex.load(:disk_message_cache, @path)
    {:ok, true}
  end

  def get_cached_disk_message(key) do
    Cachex.get!(:disk_message_cache, key)
  end

  def cache_disk_message(message) do
    Cachex.put(:disk_message_cache, message.id, message)
  end

  def dump_message_disk do
    Logger.info("dumping messages to disk")
    {:ok, true} = Cachex.dump(:disk_message_cache, @path)
  end

  def reload_from_disk do
    Logger.info("reloading data from disk")
    {:ok, true} = Cachex.load(:disk_message_cache, @path)
  end

  def get_cached_user_Ids(name) do
    CacheMessages.get(name)
  end

  def delete_cached_user_Id(key, id) do
    CacheMessages.dropId(key, id)
  end

  def cached_user_Ids(message) do
    Logger.info("User: #{message.username}")
    CacheMessages.put(message.username, message.id)
  end

  def delete_cached_id(id) do
    ConCache.delete(:message_cache, id)
  end

  def cache_message(message) do
    Logger.info("UserId: #{message.id}")
    ConCache.put(:message_cache, message.id, message)
  end

  def get_cached_message(key) do
    case ConCache.get(:message_cache, key) do
      nil ->
        false

      _ ->
        ConCache.get(:message_cache, key)
    end
  end

  # deletes message from in-memory and  also Id in cache
  # and write to cold storage
  def deleteCachedExpiredMessages(filteredexpiredMessages) do
    Enum.each(filteredexpiredMessages, fn expiredMessage ->
      Task.async(fn -> delete_cached_id(expiredMessage.id) end)
      Task.async(fn -> cache_disk_message(expiredMessage) end)
      Task.async(fn -> delete_cached_user_Id(expiredMessage.username, expiredMessage.id) end)
    end)
  end

  def handle_info({:dumpMessage}, _state) do
    # periodically dumping messages to disk
     #@interval store intervals in milliseconds in which messages are written to disk
  #  dump_message_disk()
  #  Process.send_after(self(), {:dumpMessage}, @interval)
    {:noreply, true}
  end

  def stop(:norma) do
    #  "dumping cached messages to disk"
  #  dump_message_disk()
  end
end
