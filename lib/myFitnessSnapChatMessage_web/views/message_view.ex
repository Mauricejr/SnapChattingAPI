defmodule MyFitnessSnapChatMessageWeb.MessageView do
  def render("createdResources.json", %{resource: resource}) do
    resource
  end

  def render("messagewithExpiringDate.json", %{message: message}) do
    message
  end

  def render("unExpiredMessages.json", %{unexpired_messages: unexpired_messages}) do
    unexpired_messages
  end
end
