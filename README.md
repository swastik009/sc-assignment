## Setup

1. Install Ruby (>= 2.5 recommended)
2. Run `bundle install` to install dependencies
4. Run CLI or API as shown below

## CLI Usage

Run the interactive CLI:

```sh
ruby bin/client_tool
```

## Web API & Swagger

### Start the server

```sh
ruby entrypoint.rb 
```

Server runs on [http://localhost:9292](http://localhost:9292)

### View Interactive API Docs (Swagger UI)

Open your browser and go to [http://localhost:9292](http://localhost:9292)

You will see the Swagger UI landing page with interactive documentation for all API endpoints. You can try out requests directly from the browser.

If you update `swagger.json`, refresh the page to see changes.

---

## Future Upgrades: 
- Achieve full (100%) test coverage.
- Migrate to Rails framework to leverage built-in features and enhanced security.
- Refactor by extracting a base ApplicationController, and define dedicated controllers for each resource (e.g., KeysController with an index action to list all keys).
- Optimize caching strategies and enhance memoization techniques.

### API Endpoints & Query Examples

#### 1. List all searchable fields
**GET /api/keys**

Response:
```json
["id", "full_name", "email", ...]
```

#### 2. List all clients (paginated)
**GET /api/list?page=1&per_page=5**

Query Params:
- `page` (default: 1) — Page number
- `per_page` (default: 5) — Results per page

Example:
```
GET /api/list?page=2&per_page=3
```
Response:
```json
{
  "page": 2,
  "per_page": 3,
  "total": 10,
  "clients": [ ... ]
}
```

#### 3. List clients with duplicate emails (paginated)
**GET /api/duplicates?page=1&per_page=5**

Query Params:
- `page` (default: 1)
- `per_page` (default: 5)

Example:
```
GET /api/duplicates?page=1&per_page=2
```
Response:
```json
{
  "page": 1,
  "per_page": 2,
  "total": 4,
  "duplicates": [ ... ]
}
```

#### 4. Search clients by field and query (paginated)
**GET /api/search?field=<field>&query=<query>&page=1&per_page=5**

Query Params:
- `field` (required) — Field name to search (e.g., `email`)
- `query` (required) — Exact value to match
- `page` (default: 1)
- `per_page` (default: 5)

Example:
```
GET /api/search?field=email&query=alice@example.com&page=1&per_page=2
```
Response:
```json
{
  "page": 1,
  "per_page": 2,
  "total": 1,
  "results": [ ... ]
}
```

All endpoints return JSON.

## Project Structure

- `bin/client_tool` — Simple CLI tool
- `lib/terminal_app.rb` — Interactive CLI app
- `app_loader.rb`, `api_controller.rb`, `entrypoint.rb` — Web API implementation
- `lib/client_loader.rb`, `lib/client_searcher.rb`, `lib/client.rb` — Core logic
- `data/clients.json` — Example data file


## Example JSON

```json
[
  {"id": 1, "full_name": "Alice Smith", "email": "alice@example.com"},
  {"id": 2, "full_name": "Bob Jones", "email": "bob@example.com"}
]
```


## Testing

RSpec is used for unit testing.

### Setup
1. Ensure you have run `bundle install`.
2. To run all specs:
   ```sh
   bundle exec rspec
   ```

### Coverage
- Tests cover:
  - Loading clients from JSON (including missing/invalid files)
  - Searching by any field
  - Finding duplicate emails
  - Client attribute access and formatting
  - Terminal app pagination and initialization
- Edge cases are included, such as:
  - Empty data files
  - Missing fields
  - No search results
  - Duplicate detection with multiple matches


## Documentation (YARD)

YARD is used for generating Ruby API documentation, including private methods.

### Generate Documentation

1. Make sure you have run `bundle install`.
2. Run:
   ```sh
   bundle exec yard doc
   ```
   This will generate HTML docs in the `doc/` directory.

### View Documentation

Open `doc/index.html` in your browser to view the generated documentation.


### Notes
- All public and private methods are included in the docs (see `.yardopts`).
- Markdown is supported in doc comments (no custom Markdown gem is used; YARD's default Markdown parser is sufficient).

### Live Documentation Server

To view docs locally with live search and navigation, run:
```sh
bundle exec yard server --private
```
Then open [http://localhost:8808](http://localhost:8808) in your browser.

Features:
- Search clients by any field (dynamic selection)
- List all clients
- Find duplicate emails
- Paginated results


