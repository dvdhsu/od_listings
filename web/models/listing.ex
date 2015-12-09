defmodule OdListings.Listing do
  use OdListings.Web, :model

  @primary_key {:od_id, :integer, []}
  @derive {Phoenix.Param, key: :od_id}

  schema "listings" do
    field :street, :string
    field :status, :string
    field :bedrooms, :integer
    field :bathrooms, :integer
    field :sq_ft, :integer
    field :price, :integer
    field :geometry, Geo.Point

    timestamps
  end

  @required_fields ~w(street status bedrooms bathrooms sq_ft price geometry od_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_inclusion(:status, ~w(pending active sold))
    |> unique_constraint(:od_id)
  end
end
