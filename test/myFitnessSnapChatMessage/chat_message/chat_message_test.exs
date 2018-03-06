defmodule MyFitnessSnapChatMessage.ChatMessageTest do
  use MyFitnessSnapChatMessage.DataCase

  alias MyFitnessSnapChatMessage.ChatMessage

  describe "messages" do
    alias MyFitnessSnapChatMessage.ChatMessage.Message

    @valid_attrs %{text: "some text", timeout: 42, username: "some username"}
    @update_attrs %{text: "some updated text", timeout: 43, username: "some updated username"}
    @invalid_attrs %{text: nil, timeout: nil, username: nil}

    def message_fixture(attrs \\ %{}) do
      {:ok, message} =
        attrs
        |> Enum.into(@valid_attrs)
        |> ChatMessage.create_message()

      message
    end

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert ChatMessage.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert ChatMessage.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      assert {:ok, %Message{} = message} = ChatMessage.create_message(@valid_attrs)
      assert message.text == "some text"
      assert message.timeout == 42
      assert message.username == "some username"
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ChatMessage.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      assert {:ok, message} = ChatMessage.update_message(message, @update_attrs)
      assert %Message{} = message
      assert message.text == "some updated text"
      assert message.timeout == 43
      assert message.username == "some updated username"
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = ChatMessage.update_message(message, @invalid_attrs)
      assert message == ChatMessage.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = ChatMessage.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> ChatMessage.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = ChatMessage.change_message(message)
    end
  end
end
