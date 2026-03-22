require_relative "basic_tax"
require_relative "import_tax"

# Applies all tax rules to a collection of items and exposes aggregated results.
#
# Tax rules are chained using the Chain of Responsibility pattern:
#   BasicTax → ImportTax
# Each handler decides whether it applies to a given item and delegates the rest
# to the next handler in the chain. Taxes is the single entry point — callers
# never need to know which individual rules exist.
#
# Usage:
#   taxes = Taxes.new(items)
#   taxes.total          # => 98.38  (grand total, all items, all taxes)
#   taxes.total_taxes    # => 7.90   (sum of all taxes across all items)
#   taxes.total_for(item)       # => 32.19  (total for one line)
#   taxes.tax_in_cents_for(item) # => 420   (combined tax per unit, in cents)
class Taxes
  CENTS_TO_UNIT = 100.0

  # Builds the handler chain once at construction time.
  # The chain is:  BasicTax → ImportTax  (outermost to innermost)
  def initialize(items)
    @items   = items
    @chain   = BasicTax.new(next_handler: ImportTax.new)
  end

  # Combined per-unit tax in integer cents for +item+ (basic + import).
  # All arithmetic stays in integer cents to prevent IEEE 754 drift.
  #
  # @param item [Item]
  # @return [Integer]
  def tax_in_cents_for(item)
    @chain.tax_in_cents_for(item)
  end

  # Total price for a single line (unit_price × quantity + all taxes × quantity),
  # expressed as a Float at the display boundary.
  #
  # @param item [Item]
  # @return [Float]
  def total_for(item)
    unit_price_in_cents = (item.unit_price * 100).round
    line_total_cents = (unit_price_in_cents + tax_in_cents_for(item)) * item.quantity
    line_total_cents / CENTS_TO_UNIT
  end

  # Sum of all taxes across every unit of every item in the basket.
  # Accumulates in integer cents to prevent IEEE 754 drift.
  #
  # @return [Float]
  def total_taxes
    @items.sum { |item| tax_in_cents_for(item) * item.quantity } / CENTS_TO_UNIT
  end

  # Grand total (pre-tax price + all taxes) across the entire basket.
  # Accumulates in integer cents to prevent IEEE 754 drift.
  #
  # @return [Float]
  def total
    @items.sum { |item|
      unit_price_in_cents = (item.unit_price * 100).round
      (unit_price_in_cents + tax_in_cents_for(item)) * item.quantity
    } / CENTS_TO_UNIT
  end
end
