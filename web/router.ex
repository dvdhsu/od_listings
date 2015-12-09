defmodule OdListings.Router do
  use OdListings.Web, :router

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

  scope "/", OdListings do
    pipe_through :api
    resources "/listings", ListingController, only: [:show, :index]
  end
end
