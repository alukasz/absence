defmodule AbsenceWeb.Router do
  use AbsenceWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug AbsenceWeb.AuthenticatePlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AbsenceWeb do
    pipe_through :browser

    get "/", PageController, :index

    resources "/registration", RegistrationController, only: [:new, :create]
    resources "/session", SessionController, only: [:new, :create]
    delete "/session", SessionController, :delete, as: :session

    resources "/timeoff", TimeoffController, only: [:index, :new, :create]
  end

  # Other scopes may use custom stacks.
  # scope "/api", AbsenceWeb do
  #   pipe_through :api
  # end
end
