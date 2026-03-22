# Sales Taxes

A Ruby CLI application that parses a shopping basket, applies sales tax rules, and prints a formatted receipt.

## Tax rules

- **Basic sales tax**: 10% on all items except books, food, and medical products.
- **Import duty**: 5% on all imported items, regardless of category.
- **Rounding**: every tax amount is rounded **up** to the nearest 0.05.

## Project structure

```
app.rb                        # Entry point — wires parser and formatter together
lib/
  item.rb                     # Item value object; holds tax and total calculations
  parsers/
    parser.rb                 # Parser::Base (abstract interface)
    string_parser.rb          # Parser::String — parses a multi-line input string
  formatters/
    formatter.rb              # Formatter::Base (abstract interface)
    string_formatter.rb       # Formatter::String — renders a receipt string
spec/
  app_spec.rb                 # Acceptance tests (the three sample inputs/outputs)
  lib/
    item_spec.rb
    parsers/
      parser_spec.rb
      string_parser_spec.rb
    formatters/
      formatter_spec.rb
      string_formatter_spec.rb
```

## Input format

One item per line:

```
<quantity> [imported] <product name> at <unit price>
```

Example:

```
2 book at 12.49
1 imported bottle of perfume at 47.50
```

## Running locally

Requires Ruby 4.0.2. If you use [mise](https://mise.jdx.dev/), the version is pinned in `.mise.toml`:

```sh
mise install
```

Run the app by passing the basket as a single string argument:

```sh
ruby app.rb "1 music CD at 14.99
1 imported box of chocolates at 10.00"
```

Run the test suite:

```sh
bundle install
bundle exec rspec
```

## Running with Docker

Two services are defined in `docker-compose.yml`: `app` runs the CLI, `test` runs the suite.

**Run the app** — pass the basket as the argument to the `app` service:

```sh
docker compose run app "1 music CD at 14.99
1 imported box of chocolates at 10.00"
```

**Run the tests** — use the `test` service (no argument needed):

```sh
docker compose run test
```

Or with plain Docker:

**Build the image:**

```sh
docker build -t sales-taxes .
```

**Run the app:**

```sh
docker run --rm sales-taxes "1 music CD at 14.99
1 imported box of chocolates at 10.00"
```

**Run the tests:**

```sh
docker run --rm --entrypoint bundle sales-taxes exec rspec
```

## Acceptance tests

The three canonical input/output examples from the problem statement are encoded as acceptance tests in [`spec/app_spec.rb`](spec/app_spec.rb). They cover the main scenarios:

- **Input 1** — domestic items spanning exempt (book, food) and taxable (other) categories.
- **Input 2** — imported items only, combining an exempt and a taxable product.
- **Input 3** — a mix of imported and domestic items across all three exempt categories and the taxable category.

Each test asserts the full receipt string including per-item totals, `Sales Taxes`, and `Total`. They are the canonical reference for correct behaviour and the first place to look when changing tax or formatting logic.
