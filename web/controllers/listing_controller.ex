defmodule OdListings.ListingController do
  use OdListings.Web, :controller

  alias OdListings.Listing

  def index(conn, _params) do
    listings = Repo.all(Listing)
    render(conn, "index.json", listings: listings)
  end

  def show(conn, %{"id" => id}) do
    listing = Repo.get!(Listing, id)
    render(conn, "show.json", listing: listing)
  end
end
