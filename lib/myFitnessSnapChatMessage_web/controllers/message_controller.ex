
defmodule MyFitnessSnapChatMessageWeb.MessageController do
  use MyFitnessSnapChatMessageWeb, :controller
  use AsyncWith
  plug(:validate_params when action in [:create])
  alias MyFitnessSnapChatMessage.MessageUtil
  alias MyFitnessSnapChatMessage.UniqueGeneratorIDS
  alias MyFitnessSnapChatMessage.CacheMessageActions
  alias MyFitnessSnapChatMessage.Util.MessageJasonValidator
  action_fallback(MyFitnessSnapChatMessageWeb.FallbackController)

  def create(conn, params) do
    message_map =
      case Map.has_key?(params, :timeout) do
        true ->
          timestime = MessageUtil.convertTimeUTC(params.timeout)
          MessageUtil.buildNewMessageMap(%{params | "timeout" => timestime})

        false ->
          timestime = %{
            "timeout" => MessageUtil.convertTimeUTC(),
            "id" => UniqueGeneratorIDS.nextId()
          }

          MessageUtil.buildNewMessageMap(Map.merge(params, timestime))
      end

    Task.async(fn -> CacheMessageActions.cache_message(message_map) end)
    Task.async(fn -> CacheMessageActions.cached_user_Ids(message_map) end)

    conn
    |> put_status(:created)
    |> render("createdResources.json", resource: %{id: message_map.id})
  end

  def show(conn, %{"id" => id}) do
    {parsedId, _} = Integer.parse(id)

    message =
      case CacheMessageActions.get_cached_message(parsedId) do
        false ->
          case CacheMessageActions.get_cached_disk_message(parsedId) do
            nil -> %{}
            cached_message -> MessageUtil.buildNewMessageMap(:expired, cached_message)
          end

        cached_message ->
          MessageUtil.buildNewMessageMap(:expired, cached_message)
      end

    if message == [] || message == %{} do
      conn
      |> send_resp(:not_found, "")
    else
      render(conn, "messagewithExpiringDate.json", message: message)
    end
  end

  def username(conn, %{"username" => username}) do
    cached_ids =
      with {:ok, cached_userIds} <- CacheMessageActions.get_cached_user_Ids(username) do
        cached_userIds
      else
        {:error} -> %{}
      end

    cached_msgs =
      Stream.map(cached_ids, fn id ->
        cached_message =
          Task.async(fn ->
            CacheMessageActions.get_cached_message(id)
          end)

        Task.await(cached_message)
      end)
      |> Stream.filter(fn messsage ->
        messsage != false
      end)

    filterExpiredMessages(cached_msgs)
    |> CacheMessageActions.deleteCachedExpiredMessages()

    unExpired_messages =
      filterUnEpireMessages(cached_msgs)
      |> Enum.map(fn message ->
        MessageUtil.buildNewMessageMap(:unexpired, message)
      end)

    if unExpired_messages == [] || unExpired_messages == %{} do
      conn
      |> send_resp(:not_found, "")
    else
      render(conn, "unExpiredMessages.json", unexpired_messages: unExpired_messages)
    end
  end

  defp filterExpiredMessages(expiredcachedMessages) do
    Stream.filter(expiredcachedMessages, fn message ->
      message.timeout < MessageUtil.currenTimeUTC()
    end)
  end

    defp filterUnEpireMessages(unExpiredcachedMessages) do
    Stream.filter(unExpiredcachedMessages, fn message ->
      message.timeout > MessageUtil.currenTimeUTC()
    end)
  end

  defp validate_params(conn, _params) do
    case MessageJasonValidator.validate(conn.params) do
      [] ->
        conn |> assign(:messageValidator, conn.params)

      {:error, error} ->
        conn |> put_status(422) |> json(%{errors: error}) |> halt
    end
  end
end
