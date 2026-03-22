class Item
  # Multiplier used to convert a decimal unit price to integer cents.
  CENTS_PER_UNIT = 100

  # Divisor used to convert integer cents back to a decimal unit price.
  # Kept as a Float so the result of division is always a Float.
  CENTS_TO_UNIT = 100.0

  # Basic sales tax rate applied to all items (10%).
  # Stored as an integer percentage to keep all tax arithmetic in integers
  # and avoid introducing a float at the point of rate definition.
  BASIC_TAX_RATE_PERCENT = 10

  # Categories exempt from basic sales tax.
  BASIC_TAX_EXEMPT_CATEGORIES = %i[book food medical].freeze

  # Import duty rate applied to imported items (5%).
  # Stored as an integer percentage to keep all tax arithmetic in integers
  # and avoid introducing a float at the point of rate definition.
  IMPORT_TAX_RATE_PERCENT = 5

  # Divisor that converts an integer percentage to a fractional multiplier.
  # e.g. 5 / 100.0 == 0.05  (kept as a constant for symmetry with CENTS_TO_UNIT)
  PERCENT_TO_RATE = 100.0

  # Maps each known product name (singular and plural) to its category.
  #
  # NOTE: This is not an ideal solution. Hardcoding product names here means
  # every new product must be manually added to this list, and matching by name
  # fragment is brittle — a product like "chocolate perfume" would be
  # misclassified because its name contains a word that belongs to a different
  # category. A proper solution would store the category as explicit data on the
  # product (e.g. a database column or a dedicated field in the input format).
  CATEGORIES = {
    "book"                        => :book,
    "books"                       => :book,
    "box of chocolates"           => :food,
    "boxes of chocolates"         => :food,
    "chocolate bar"               => :food,
    "chocolate bars"              => :food,
    "packet of headache pills"    => :medical,
    "packets of headache pills"   => :medical
  }.freeze

  attr_reader :quantity, :imported, :name, :unit_price, :category

  def initialize(quantity:, imported:, name:, unit_price:)
    @quantity   = quantity
    @imported   = imported
    @name       = name
    @unit_price = unit_price
    @category   = CATEGORIES.fetch(name.downcase, :other)
  end

  def imported?
    @imported
  end

  # Returns the total price for this item (unit_price × quantity),
  # including basic sales tax and import tax when applicable.
  #
  # All arithmetic is performed in integer cents to prevent floating-point
  # rounding errors. See +unit_price_in_cents+ and +cents_to_unit+ for details.
  def total
    cents_to_unit((unit_price_in_cents + basic_tax_in_cents + import_tax_in_cents) * quantity)
  end

  # Returns the basic sales tax per unit (10% of unit_price).
  def basic_tax
    cents_to_unit(basic_tax_in_cents)
  end

  # Returns the import tax per unit, or 0.0 when the item is not imported.
  def import_tax
    cents_to_unit(import_tax_in_cents)
  end

  private

  # Converts unit_price to an integer number of cents.
  #
  # Floating-point numbers (IEEE 754) cannot represent most decimal fractions
  # exactly — e.g. 0.1 + 0.2 evaluates to 0.30000000000000004, not 0.3.
  # Multiplying by 100 and rounding to the nearest integer eliminates any
  # representation error present in the incoming float before any further
  # arithmetic is done.
  def unit_price_in_cents
    (unit_price * CENTS_PER_UNIT).round
  end

  # Returns the basic sales tax for one unit as an integer number of cents.
  #
  # The rate is applied entirely in integer arithmetic:
  #   (price_in_cents × rate_percent) / 100
  # Dividing once at the end is the only floating-point step, mirroring
  # the same boundary strategy used in +cents_to_unit+.
  # Returns 0 for items in exempt categories (book, food, medical).
  def basic_tax_in_cents
    return 0 if BASIC_TAX_EXEMPT_CATEGORIES.include?(category)

    (unit_price_in_cents * BASIC_TAX_RATE_PERCENT / PERCENT_TO_RATE).round
  end

  # Returns the import tax for one unit as an integer number of cents.
  #
  # The rate is applied entirely in integer arithmetic:
  #   (price_in_cents × rate_percent) / 100
  # Dividing once at the end is the only floating-point step, mirroring
  # the same boundary strategy used in +cents_to_unit+.
  # Returns 0 for non-imported items.
  def import_tax_in_cents
    return 0 unless imported?

    (unit_price_in_cents * IMPORT_TAX_RATE_PERCENT / PERCENT_TO_RATE).round
  end

  # Converts an integer cent amount back to a decimal unit price.
  #
  # This is the only floating-point operation in the calculation chain and only
  # happens at the final display boundary, so rounding errors have no chance to
  # accumulate across multiple operations.
  def cents_to_unit(cents)
    cents / CENTS_TO_UNIT
  end
end
