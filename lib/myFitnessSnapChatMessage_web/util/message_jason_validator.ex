defmodule MyFitnessSnapChatMessage.Util.MessageJasonValidator do
  use GenServer
  alias MyFitnessSnapChatMessage.MessageUtil

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_) do
    schema = MessageUtil.schema()
    {:ok, schema}
  end

  def handle_call({:validate, request_params}, _from, schema) do
    validatScehema = schema.schema["text_message"]["definitions"]

    result =
      case ExJsonSchema.Validator.validate(validatScehema, request_params) do
        :ok -> []
        {:error, errors} -> {:error, errors_to_json(errors)}
      end

    {:reply, result, schema}
  end

  def validate(request_params) do
    GenServer.call(__MODULE__, {:validate, request_params})
  end

  def errors_to_json(errors) do
    errors |> Enum.map(fn {msg, _cols} -> msg end)
  end
end
