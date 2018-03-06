defmodule MyFitnessSnapChatMessage.MessageUtil do
  use Timex
  @defaultSeconds 60

  defmodule Messages do
    @derive [Poison.Encoder]
    defstruct [:id, :username, :text, :timeout]
  end

  def convertTimeUTC(sencods_api \\ @defaultSeconds) do
    IO.inspect(sencods_api)
  DateTime.to_unix(Timex.shift(Timex.now, seconds: +sencods_api))
  end

  def buildNewMessageMap(message) do
    %{
      username: Map.get(message, "username"),
      timeout: Map.get(message, "timeout"),
      text: Map.get(message, "text"),
      id: Map.get(message, "id")
    }
  end

  def currenTimeUTC do
    DateTime.to_unix(Timex.shift(Timex.now(), seconds: +0))
  end

 def get_EpochTime(epochTinme)do
 DateTime.from_unix!(epochTinme, :second) |> DateTime.to_naive() |> to_string()
end

  def buildNewMessageMap(:expired, message) do
    %{username: message.username, text: message.text, expiration_date: get_EpochTime(message.timeout)}
  end

  def buildNewMessageMap(:unexpired, message) do
    %{id: message.id, text: message.text}
  end

  def getTime(message) do
    %{username: message.username, timeout: get_EpochTime(message.timeout), text: message.text, id: message.id}
  end

 #  schema validator
  def schema do
    %{
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "title" => "text message API Schema",
      "text_message" => %{
        "definitions" => %{
          "type" => "object",
          "required" => ["text", "username"],
          "properties" => %{
            "text" => %{
              "type" => "string"
            },
            "username" => %{
              "type" => "string"
            },
            "timeout" => %{
              "type" => "integer"
            },
          }
        }
      }
    }
    |> ExJsonSchema.Schema.resolve()
  end
end
