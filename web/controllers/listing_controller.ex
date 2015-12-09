defmodule OdListings.ListingController do
  use OdListings.Web, :controller
  import Ecto.Query
  alias OdListings.Listing

  def index(conn, _params) do
    cleaned_params = clean_params _params

    listings = Listing
    |> params_to_query(cleaned_params)
    |> Repo.all
    render(conn, "index.json", listings: listings)
  end

  def show(conn, %{"id" => id}) do
    listing = Repo.get!(Listing, id)
    render(conn, "show.json", listing: listing)
  end

  defp params_to_query(init_query, params) do
    Enum.reduce(params, init_query, fn {k, v}, query ->
      case k do
        "min_price" -> query |> where([l], l.price >= ^v)
        "max_price" -> query |> where([l], l.price <= ^v)
        "min_bed"   -> query |> where([l], l.bedrooms >= ^v)
        "max_bed"   -> query |> where([l], l.bedrooms <= ^v)
        "min_bath"  -> query |> where([l], l.bathrooms >= ^v)
        "max_bath"  -> query |> where([l], l.bathrooms <= ^v)
        _ -> query
      end
    end)
  end

  defp clean_params(params) do
    params
    |> Enum.filter fn {k, v} ->
      # if we can convert it to an integer,  we allow; otherwise not
      try do String.to_integer(v); true rescue ArgumentError -> false end
    end
  end
end
