defmodule MyFitnessSnapChatMessage.CacheMessageActions do
  alias MyFitnessSnapChatMessage.CacheMessages
  use AsyncWith
  @path "./priv/database_dump/messages"
  require Logger
  use ExActor.GenServer

  #@interval 5000
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
    Logger.info("dumping data to disk")
    Cachex.put(:disk_message_cache, message.id, message)
  end

  def dump_message_disk do
    {:ok, true} = Cachex.dump(:disk_message_cache, @path)
  end

  def reload_from_disk do
      Logger.info("reloading data from disk")
    {:ok, true} = Cachex.load(:disk_message_cache, @path)
  end

  def get_cached_user_Ids(name) do
    CacheMessages.get(name)
  end

  # def get_cachedAlluserIds do
  #   CacheMessages.getAllUserIds
  # end


  def delete_cached_user_Id(key, id) do
    CacheMessages.dropId(key, id)
  end

  def cached_user_Ids(message) do
    Logger.info("User")
    Logger.info(message.username)
    CacheMessages.put(message.username, message.id)
  end

  def delete_cached_id(id) do
    ConCache.delete(:message_cache, id)
  end

  def cache_message(message) do
    Logger.info("UserId")
    Logger.info( message.id)
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

  def deleteCachedExpiredMessages(filteredexpiredMessages) do
    Enum.each(filteredexpiredMessages, fn expiredMessage ->
      Task.async(fn -> delete_cached_id(expiredMessage.id) end)
      Task.async(fn -> cache_disk_message(expiredMessage) end)
      Task.async(fn -> delete_cached_user_Id(expiredMessage.username, expiredMessage.id) end)
    end)
  end

  def handle_info({:dumpMessage}, _state) do
  #  dump_message_disk()
  #  Process.send_after(self(), {:dumpMessage}, @interval)
    {:noreply, true}
  end

  def stop(:norma) do
  #  "dumping cached messages into disk"
    #dump_message_disk()
  end
end
