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

Build and run with `docker compose`:

```sh
docker compose run app "1 music CD at 14.99
1 imported box of chocolates at 10.00"
```

Or build and run with plain Docker:

```sh
docker build -t sales-taxes .
docker run --rm sales-taxes "1 music CD at 14.99
1 imported box of chocolates at 10.00"
```

## Sample output

Input:
```
1 imported bottle of perfume at 27.99
1 bottle of perfume at 18.99
1 packet of headache pills at 9.75
3 imported boxes of chocolates at 11.25
```

Output:
```
1 imported bottle of perfume: 32.19
1 bottle of perfume: 20.89
1 packet of headache pills: 9.75
3 imported boxes of chocolates: 35.55
Sales Taxes: 7.90
Total: 98.38
```
