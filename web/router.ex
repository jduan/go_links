defmodule GoLinks.Router do
  use GoLinks.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GoLinks do
    pipe_through :browser # Use the default browser stack

    get "/pages/faq", PageController, :faq
    get "/", LinkController, :index
    resources "/links", LinkController
    get "/*path", RedirectController, :handle_redirect
  end

  # Other scopes may use custom stacks.
  # scope "/api", GoLinks do
  #   pipe_through :api
  # end
end
