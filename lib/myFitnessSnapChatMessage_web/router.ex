defmodule MyFitnessSnapChatMessageWeb.Router do
  use MyFitnessSnapChatMessageWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end
  scope "/api", MyFitnessSnapChatMessageWeb do
      pipe_through :api
      resources "/chat", MessageController
      get "/chats", MessageController, :username
    end

end
