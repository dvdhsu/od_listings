defmodule Mix.Tasks.ImportListings do
  use Mix.Task

  alias OdListings.Listing

  @shortdoc "Imports listings via a CSV file as specified."

  def run(filename) do
    # to ensure that we can access the repo
    Application.ensure_all_started(:od_listings)

    File.stream!(filename)
    |> CSV.decode(headers: true)
    |> Enum.map fn row ->
      {lng, lat} = {row["lng"], row["lat"]}

      parsed = row
      # convert long lat to a geometry
      |> Dict.put("geometry", Geo.WKT.decode("POINT(#{lng} #{lat})"))
      # convert the id to our internal representation, the od_id
      |> Dict.put("od_id", Dict.get(row, "id"))

      add_listing %{"listing" => parsed}
    end
  end

  def add_listing(%{"listing" => listing_params}) do
    changeset = Listing.changeset(%Listing{}, listing_params)

    case OdListings.Repo.insert(changeset) do
      # if fails, just terminate, instead of catching, since we want to know
      {:ok, listing} ->
        Mix.shell.info  "Inserted listing."
    end
  end
end
