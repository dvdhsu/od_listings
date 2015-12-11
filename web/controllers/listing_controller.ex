defmodule OdListings.ListingController do
  use OdListings.Web, :controller
  import Ecto.Query
  alias OdListings.Listing

  def index(conn, _params) do
    cleaned_params = clean_params _params

    page = Listing
    |> params_to_query(cleaned_params)
    |> sort_by(_params)
    |> Repo.paginate(_params)

    conn
    |> put_pagination_headers(page)
    |> render "index.json", listings: page.entries
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

  defp sort_by(query, params) do
    query = case params["sort_by"] do
      "price_asc" ->  query |> order_by([l], asc: l.price)
      "bed_asc" ->    query |> order_by([l], asc: l.bedrooms)
      "bath_asc" ->   query |> order_by([l], asc: l.bathrooms)
      "price_desc" -> query |> order_by([l], desc: l.price)
      "bed_desc" ->   query |> order_by([l], desc: l.bedrooms)
      "bath_desc" ->  query |> order_by([l], desc: l.bathrooms)
      _ -> query
    end
    query
  end

  defp clean_params(params) do
    params
    |> Enum.filter fn {k, v} ->
      # if we can convert it to an integer,  we allow; otherwise not
      try do String.to_integer(v); true rescue ArgumentError -> false end
    end
  end

  defp put_pagination_headers(conn, page) do
    # contains all links
    link_hash = %{}
    |> Dict.put("first", if page.total_pages > 1 && page.page_number != 1 do 1 end)
    |> Dict.put("last",  if page.total_pages > 1 && page.page_number != page.total_pages do page.total_pages end)
    |> Dict.put("prev", if (page.page_number > 1) do page.page_number - 1 end)
    |> Dict.put("next", if (page.page_number < page.total_pages) do page.page_number + 1 end)

    # the relative path to use in the links, not including params
    path = conn.request_path <> "?"

    header_data = Enum.reduce(link_hash, [], fn({k ,v}, link_list) ->
      unless is_nil(v) do
        # now add in the params, merging it with the new page link
        params_as_string = Dict.merge(conn.params, %{"page" => to_string(v)})
        |> Enum.map(fn {key, value} -> (key <> "=" <> value) end)
        |> Enum.join("&")

        link = path <> params_as_string
        # format the single link according to RFC 5988
        link_list = link_list ++ [Enum.join(["<", link, ">; rel=\"", k, "\""], "")]
      end
      link_list
    end)

    # join all links together according to RFC 5988, and put in header
    conn |> put_resp_header("link", Enum.join(header_data, ", "))
  end
end
