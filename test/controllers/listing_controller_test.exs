defmodule OdListings.ListingControllerTest do
  use OdListings.ConnCase
  use ExSpec, async: true

  alias OdListings.Listing

  setup do
    listing_params = [
      %{od_id: 1, bathrooms: 2, bedrooms: 3, sq_ft: 1000, status: "sold",
        street: "156 Lois Lane", price: 500000, geometry: Geo.WKT.decode "POINT(90
        90)"},
      %{od_id: 2, bathrooms: 1, bedrooms: 1, sq_ft: 500, status: "pending",
        street: "156 Lois Lane", price: 250000, geometry: Geo.WKT.decode "POINT(90
        90)"}
    ]
    listings = Enum.reduce listing_params, [], fn l, insertions ->
      changeset = Listing.changeset(%Listing{}, l)
      insertions ++ [(Repo.insert! changeset)]
    end

    conn() |> put_req_header("accept", "application/json")
    {:ok, conn: conn, listings: listings}
  end

  it "shows the correct index", %{conn: conn, listings: listings} do
    conn = get conn, listing_path(conn, :index)
    assert json_response(conn, 200)["type"] == "FeatureCollection"
    assert (length json_response(conn, 200)["features"]) == length listings
  end

  it "shows chosen resource", %{conn: conn, listings: listings} do
    listing = hd listings
    conn = get conn, listing_path(conn, :show, listing)
    assert json_response(conn, 200)["type"] == "Feature"
    assert json_response(conn, 200)["properties"] == %{"id" => listing.od_id,
      "street" => listing.street,
      "price" => listing.price,
      "bedrooms" => listing.bedrooms,
      "bathrooms" => listing.bathrooms,
      "sq_ft" => listing.sq_ft}
    assert json_response(conn, 200)["geometry"]["type"] == "Point"
    assert json_response(conn, 200)["geometry"]["coordinates"] == [90, 90]
  end

  it "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, listing_path(conn, :show, -1)
    end
  end

  describe "sort" do
    context "prices" do
      it "by asc" do
        conn = get conn, listing_path(conn, :index), %{sort_by: "price_asc"}
        assert json_response(conn, 200)["type"] == "FeatureCollection"
        assert (length json_response(conn, 200)["features"]) == 2
        min = (hd json_response(conn, 200)["features"])["properties"]["price"]
        Enum.map json_response(conn, 200)["features"], fn l ->
          assert l["properties"]["price"] >= min
          min = l["properties"]["price"]
        end
      end

      it "by desc" do
        conn = get conn, listing_path(conn, :index), %{sort_by: "price_desc"}
        assert json_response(conn, 200)["type"] == "FeatureCollection"
        assert (length json_response(conn, 200)["features"]) == 2
        max = (hd json_response(conn, 200)["features"])["properties"]["price"]
        Enum.map json_response(conn, 200)["features"], fn l ->
          assert l["properties"]["price"] <= max
          max = l["properties"]["price"]
        end
      end
    end

    context "bedrooms" do
      it "by asc" do
        conn = get conn, listing_path(conn, :index), %{sort_by: "bed_asc"}
        assert json_response(conn, 200)["type"] == "FeatureCollection"
        assert (length json_response(conn, 200)["features"]) == 2
        min = (hd json_response(conn, 200)["features"])["properties"]["bed"]
        Enum.map json_response(conn, 200)["features"], fn l ->
          assert l["properties"]["bed"] >= min
          min = l["properties"]["bed"]
        end
      end

      it "by desc" do
        conn = get conn, listing_path(conn, :index), %{sort_by: "bed_desc"}
        assert json_response(conn, 200)["type"] == "FeatureCollection"
        assert (length json_response(conn, 200)["features"]) == 2
        max = (hd json_response(conn, 200)["features"])["properties"]["bed"]
        Enum.map json_response(conn, 200)["features"], fn l ->
          assert l["properties"]["bed"] <= max
          max = l["properties"]["bed"]
        end
      end
    end

    context "bathrooms" do
      it "by asc" do
        conn = get conn, listing_path(conn, :index), %{sort_by: "bath_asc"}
        assert json_response(conn, 200)["type"] == "FeatureCollection"
        assert (length json_response(conn, 200)["features"]) == 2
        min = (hd json_response(conn, 200)["features"])["properties"]["bath"]
        Enum.map json_response(conn, 200)["features"], fn l ->
          assert l["properties"]["bath"] >= min
          min = l["properties"]["bath"]
        end
      end

      it "by desc" do
        conn = get conn, listing_path(conn, :index), %{sort_by: "bath_desc"}
        assert json_response(conn, 200)["type"] == "FeatureCollection"
        assert (length json_response(conn, 200)["features"]) == 2
        max = (hd json_response(conn, 200)["features"])["properties"]["bath"]
        Enum.map json_response(conn, 200)["features"], fn l ->
          assert l["properties"]["bath"] <= max
          max = l["properties"]["bath"]
        end
      end
    end

    context "sq_ft" do
      it "by asc" do
        conn = get conn, listing_path(conn, :index), %{sort_by: "sqft_asc"}
        assert json_response(conn, 200)["type"] == "FeatureCollection"
        assert (length json_response(conn, 200)["features"]) == 2
        min = (hd json_response(conn, 200)["features"])["properties"]["sq_ft"]
        Enum.map json_response(conn, 200)["features"], fn l ->
          assert l["properties"]["sq_ft"] >= min
          min = l["properties"]["sq_ft"]
        end
      end

      it "by desc" do
        conn = get conn, listing_path(conn, :index), %{sort_by: "sqft_desc"}
        assert json_response(conn, 200)["type"] == "FeatureCollection"
        assert (length json_response(conn, 200)["features"]) == 2
        max = (hd json_response(conn, 200)["features"])["properties"]["sqft"]
        Enum.map json_response(conn, 200)["features"], fn l ->
          assert l["properties"]["sqft"] <= max
          max = l["properties"]["sqft"]
        end
      end
    end
  end

  describe "filter" do
    it "by all" do
      conn = get conn, listing_path(conn, :index), %{
        min_price: "100000",
        max_price: "500000",
        min_bed: "1",
        max_bed: "3",
        min_bath: "1",
        max_bath: "3",
      }
      assert json_response(conn, 200)["type"] == "FeatureCollection"
      assert (length json_response(conn, 200)["features"]) == 2
    end

    it "ignores spurious paramters" do
      conn = get conn, listing_path(conn, :index), %{foo: "13"}
      assert json_response(conn, 200)["type"] == "FeatureCollection"
      assert (length json_response(conn, 200)["features"]) == 2
    end

    context "prices" do
      it "by max" do
        conn = get conn, listing_path(conn, :index), %{max_price: "250000"}
        assert json_response(conn, 200)["type"] == "FeatureCollection"
        assert (length json_response(conn, 200)["features"]) == 1
        Enum.map json_response(conn, 200)["features"], fn l ->
          refute is_nil l["properties"]["price"]
          assert l["properties"]["price"] <= 250000
        end
      end

      it "by min" do
        conn = get conn, listing_path(conn, :index), %{min_price: "300000"}
        assert json_response(conn, 200)["type"] == "FeatureCollection"
        assert (length json_response(conn, 200)["features"]) == 1
        Enum.map json_response(conn, 200)["features"], fn l ->
          refute is_nil l["properties"]["price"]
          assert l["properties"]["price"] >= 300000
        end
      end
    end

    context "bedrooms" do
      it "by max" do
        conn = get conn, listing_path(conn, :index), %{max_bed: "2"}
        assert json_response(conn, 200)["type"] == "FeatureCollection"
        assert (length json_response(conn, 200)["features"]) == 1
        Enum.map json_response(conn, 200)["features"], fn l ->
          refute is_nil l["properties"]["bedrooms"]
          assert l["properties"]["bedrooms"] <= 2
        end
      end

      it "by min" do
        conn = get conn, listing_path(conn, :index), %{min_bed: "2"}
        assert json_response(conn, 200)["type"] == "FeatureCollection"
        assert (length json_response(conn, 200)["features"]) == 1
        Enum.map json_response(conn, 200)["features"], fn l ->
          refute is_nil l["properties"]["bedrooms"]
          assert l["properties"]["bedrooms"] >= 2
        end
      end
    end

    context "bathrooms" do
      it "by max" do
        conn = get conn, listing_path(conn, :index), %{max_bath: "2"}
        assert json_response(conn, 200)["type"] == "FeatureCollection"
        assert (length json_response(conn, 200)["features"]) == 2
        Enum.map json_response(conn, 200)["features"], fn l ->
          refute is_nil l["properties"]["bathrooms"]
          assert l["properties"]["bathrooms"] <= 2
        end
      end

      it "by min" do
        conn = get conn, listing_path(conn, :index), %{min_bath: "2"}
        assert json_response(conn, 200)["type"] == "FeatureCollection"
        assert (length json_response(conn, 200)["features"]) == 1
        Enum.map json_response(conn, 200)["features"], fn l ->
          refute is_nil l["properties"]["bathrooms"]
          assert l["properties"]["bathrooms"] >= 2
        end
      end
    end

    context "sq_ft" do
      it "by max" do
        conn = get conn, listing_path(conn, :index), %{max_sqft: "500"}
        assert json_response(conn, 200)["type"] == "FeatureCollection"
        assert (length json_response(conn, 200)["features"]) == 1
        Enum.map json_response(conn, 200)["features"], fn l ->
          refute is_nil l["properties"]["sq_ft"]
          assert l["properties"]["sq_ft"] <= 500
        end
      end

      it "by min" do
        conn = get conn, listing_path(conn, :index), %{min_sqft: "500"}
        assert json_response(conn, 200)["type"] == "FeatureCollection"
        assert (length json_response(conn, 200)["features"]) == 2
        Enum.map json_response(conn, 200)["features"], fn l ->
          refute is_nil l["properties"]["sq_ft"]
          assert l["properties"]["sq_ft"] >= 500
        end
      end
    end
  end
end
