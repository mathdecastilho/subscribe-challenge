# Handles the import duty rule in the chain of responsibility.
#
# Import tax is 5% on all imported items, regardless of category.
# The tax per unit is rounded UP to the nearest 5 cents before being applied.
#
# It calls the next handler in the chain (if any) and adds its own result on top.
class ImportTax
  RATE_PERCENT               = 5
  PERCENT_TO_RATE            = 100.0
  ROUNDING_GRANULARITY_CENTS = 5

  # @param next_handler [#tax_in_cents_for, nil]  next link in the chain, or nil
  def initialize(next_handler: nil)
    @next_handler = next_handler
  end

  # Returns the total tax (import duty + downstream handlers) for one unit of
  # +item+, expressed in integer cents.
  #
  # @param item [Item]
  # @return [Integer] tax in cents (per unit)
  def tax_in_cents_for(item)
    own_tax = calculate(item)
    downstream_tax = @next_handler ? @next_handler.tax_in_cents_for(item) : 0
    own_tax + downstream_tax
  end

  private

  def applies_to?(item)
    item.imported?
  end

  def calculate(item)
    return 0 unless applies_to?(item)

    unit_price_in_cents = (item.unit_price * 100).round
    raw = unit_price_in_cents * RATE_PERCENT / PERCENT_TO_RATE
    (raw / ROUNDING_GRANULARITY_CENTS).ceil * ROUNDING_GRANULARITY_CENTS
  end
end
