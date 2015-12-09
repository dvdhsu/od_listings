defmodule OdListings.ListingView do
  use OdListings.Web, :view

  def render("index.json", %{listings: listings}) do %{
    type: "FeatureCollection",
    features: render_many(listings, OdListings.ListingView, "listing.json")
  } end

  def render("show.json", %{listing: listing}) do
    render_one(listing, OdListings.ListingView, "listing.json")
  end

  def render("listing.json", %{listing: listing}) do %{
    type: "Feature",
    properties: %{
      id: listing.od_id,
      price: listing.price,
      street: listing.street,
      bedrooms: listing.bedrooms,
      bathrooms: listing.bathrooms,
      sq_ft: listing.sq_ft,
    },
    geometry: Geo.JSON.encode(listing.geometry)
  } end
end
