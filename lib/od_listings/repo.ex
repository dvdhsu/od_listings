defmodule OdListings.Repo do
  use Ecto.Repo, otp_app: :od_listings
  use Scrivener, page_size: 50
end
