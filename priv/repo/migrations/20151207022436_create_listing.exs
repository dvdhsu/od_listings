defmodule OdListings.Repo.Migrations.CreateListing do
  use Ecto.Migration

  def change do
    create table(:listings, primary_key: false) do
      add :od_id, :integer, primary_key: true
      add :street, :string
      add :status, :string
      add :bedrooms, :integer
      add :bathrooms, :integer
      add :sq_ft, :integer
      add :price, :integer
      add :geometry, :geometry

      timestamps
    end

    create index(:listings, [:status])
    create index(:listings, [:price])
    create index(:listings, [:sq_ft])
    create index(:listings, [:bedrooms])
    create index(:listings, [:bathrooms])
  end
end
