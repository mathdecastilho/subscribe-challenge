class Item
  # Multiplier used to convert a decimal unit price to integer cents.
  CENTS_PER_UNIT = 100

  # Divisor used to convert integer cents back to a decimal unit price.
  # Kept as a Float so the result of division is always a Float.
  CENTS_TO_UNIT  = 100.0

  attr_reader :quantity, :imported, :name, :unit_price

  def initialize(quantity:, imported:, name:, unit_price:)
    @quantity   = quantity
    @imported   = imported
    @name       = name
    @unit_price = unit_price
  end

  def imported?
    @imported
  end

  # Returns the total price for this item (unit_price × quantity).
  #
  # All arithmetic is performed in integer cents to prevent floating-point
  # rounding errors. See +unit_price_in_cents+ and +cents_to_unit+ for details.
  def total
    cents_to_unit(unit_price_in_cents * quantity)
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

  # Converts an integer cent amount back to a decimal unit price.
  #
  # This is the only floating-point operation in the calculation chain and only
  # happens at the final display boundary, so rounding errors have no chance to
  # accumulate across multiple operations.
  def cents_to_unit(cents)
    cents / CENTS_TO_UNIT
  end
end
