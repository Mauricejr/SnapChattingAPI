defmodule MyFitnessSnapChatMessageWeb.MessageController do
  use MyFitnessSnapChatMessageWeb, :controller
  use AsyncWith
  plug(:validate_params when action in [:create])
  alias MyFitnessSnapChatMessage.MessageUtil
  #alias MyFitnessSnapChatMessage.UniqueGeneratorIDS
  alias MyFitnessSnapChatMessage.CacheMessageActions
  alias MyFitnessSnapChatMessage.Util.MessageJasonValidator
  action_fallback(MyFitnessSnapChatMessageWeb.FallbackController)

  def create(conn, params) do
    {:ok, id} = Snowflake.next_id()
    message_map =
      case Map.has_key?(params, "timeout") do
        true ->
          timestime = MessageUtil.convertTimeUTC(params["timeout"])
          newMapWithId = Map.merge(params, %{"id" => id})
          MessageUtil.buildNewMessageMap(%{newMapWithId | "timeout" => timestime})

        false ->

          timestime = %{
            "timeout" => MessageUtil.convertTimeUTC(),
            "id" => id
            #UniqueGeneratorIDS.nextId()
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

    # get message from in-memory or cold disk
    message =
      case CacheMessageActions.get_cached_message(parsedId) do
        false ->
          # get message from cold disk or return no found
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
    cached_msgs =
      with {:ok, cached_userIds} <- CacheMessageActions.get_cached_user_Ids(username) do
          Stream.map(cached_userIds, fn id ->
            cached_message =
              Task.async(fn ->
                CacheMessageActions.get_cached_message(id)
              end)

            Task.await(cached_message)
          end)
          |> Stream.filter(fn messsage ->
            messsage != false
          end)
      else
        {:error} -> %{}
      end

    unExpired_messages =
      cached_msgs
      |> Enum.map(fn message ->
        MessageUtil.buildNewMessageMap(:unexpired, message)
      end)

    filterExpiredMessages(cached_msgs)
    |> CacheMessageActions.deleteCachedExpiredMessages()

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

  # defp filterUnEpireMessages(unExpiredcachedMessages) do
  #   Stream.filter(unExpiredcachedMessages, fn message ->
  #     message.timeout > MessageUtil.currenTimeUTC()
  #   end)
  # end

  defp validate_params(conn, _params) do
    case MessageJasonValidator.validate(conn.params) do
      [] ->
        conn |> assign(:messageValidator, conn.params)

      {:error, error} ->
        conn |> put_status(422) |> json(%{errors: error}) |> halt
    end
  end
end
