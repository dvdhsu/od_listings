defmodule OdListings.ListingTest do
  use OdListings.ModelCase

  alias OdListings.Listing

  @valid_attrs %{od_id: 1, bathrooms: 42, bedrooms: 42, sq_ft: 42, status: "pending",
    street: "156 Lois Lane", price: 100000, geometry: Geo.WKT.decode "POINT(90
    90)"}
  @invalid_attrs %{}
  @invalid_status %{od_id: 1, bathrooms: 42, bedrooms: 42, sq_ft: 42, status: "foo",
    street: "156 Lois Lane", price: 100000, geometry: Geo.WKT.decode "POINT(90
    90)"}

  test "changeset with valid attributes" do
    changeset = Listing.changeset(%Listing{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Listing.changeset(%Listing{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with invalid status" do
    changeset = Listing.changeset(%Listing{}, @invalid_status)
    refute changeset.valid?
  end
end
