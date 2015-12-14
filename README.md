# OdListings

To start:

  1. Install dependencies with `mix deps.get`.
  2. Create and migrate your database with `mix ecto.create && mix ecto.migrate`.
  3. Import the listings with `mix import_listings "listings.csv"`.
  4. Start endpoint with `mix phoenix.server`. Access on port 4005.

## Notes

  * Importing listings is done a via a Mix task, as specified above. This is similar to a Rake task in Ruby.
  * I've added a few extra features, including:
    * showing a specific resource by id (e.g. GET `listings/3`)
    * additional filters (e.g. `sqft`)
    * sorting (e.g. `?sort_by=price_desc`)
    * paging, according to RFC 5988
  * Because this was built in Elixir and Phoenix (see below), the code is verbose, since Elixir has less library functions than Ruby / Python. I've also made a [Ruby version](https://github.com/dvdhsu/od_listings_ruby "ruby") (took like 1.5h, with paging), just to prove that a) I can move  quickly, and b) I am capable of writing concise code utilizing library functions.
    * examples of where the code could be improved include:
      * adding pagination headers, where I convert from a hash of params to a string. I use some higher order functions like `reduce`, and `map`, which look slightly mysterious. In Ruby, the same effect is achieved with just a `to_param`.
        * I actually tried to use Phoenix's internal function to do this, but it only took structs, instead of dicts. I could've made a quick and dirty conversion, but just writing the code out seemed simpler to me.
      * when I clean the params, I'm forced to use a try / catch, since Erlang library functions don't follow the `{:ok, _}` idiom in Elixir. Instead, they throw exceptions! I should probably make a wrapper for this sometime...

## API documentation

### GET /listings

  * Returns all the listings as a GeoJSON FeatureColection.
  * Supports filtering via `min_bed`, `max_bed`, `min_bath`, `max_bath`, `min_price`, `max_price`, `min_sqft`, and `max_sqft`.
    * e.g.  `http://localhost:4005/listings?min_price=200000&max_price=250000&min_bed=2&max_bed=3&min_bath=2&max_bath=2`
  * Supports sorting by `price_asc`, `bed_asc`, `bath_asc`, as well as `price_desc`, `bed_desc`, and `bath_desc`. 
    * e.g. `http://localhost:4005/listings?sort_by=bed_desc`
  * Results are paged according to RFC 5988.

### GET /listings/:id
  * Returns a specific listing as a GeoJSON Feature.

## Design Decisions

  * I used Elixir / Phoenix since I've been using them for some side projects, and found both really interesting, coming from a Ruby / RoR background. Also heard that OD uses ELixir as well, so another +1.
  * I only exposed `show` and `index` API endpoints. `create`, `destroy`, `update`, etc. are not exposed, since there is no frontend. This could be a further feature.
  * Added indicies for `bathrooms`, `bedrooms`, `price`, `sq_ft` and `status`.
    * First four are for filtering and sorting quickly (saves us a linear scan through the table).
    * Indicies speed up lookup, but slow down insertion. Since the data was bulk inserted anyways, and insertions in this domain don't happen *that* frequently (only when a new home is listed on OD), the tradeoff is worth it.
  * PostGIS is used for the geometries. This is so we can add some pretty cool features later on, like filtering within polygons, sorting / searching by distance from a point, etc.
  * The id found in the CSV (`od_id`) is used as the primary id.
  * Validations:
    * `status` must be one of `pending`, `active`, or `sold`.
    * `od_id` must be unique.

## Future

  * If this were an actual project I were working on, I'd probably:
    * add searching by point, since:
      * location of a listing is extremely important
      * as OD expands into new cities / areas, doing filtering by a `city` field doesn't really scale.
    * add filtering within geometries (e.g. polygons), so we could scroll around on a map and load new listings
    * support adding listings, via some sort of admin interface
      * to build it quickly, I'd just use scaffolding, then hook in reverse-geocoding to get the long/lat from address
    * deploy in production, and fix error pages
      * currently, this is running in development mode (even on my server), since deploying Erlang into production is somewhat convoluted. This leads to unsafe error pages (some of them have consoles embedded!), as well as non-JSON error messages.
    * add some new filters
      * by status, for example
    * bolster up pagination headers
      * currently, if you try accessing a non-existent page, the `prev` link is still there.
    * possibly add in more security, such as rate limiting, auth tokens, etc.
