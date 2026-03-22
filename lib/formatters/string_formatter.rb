require_relative "formatter"
require_relative "../taxes/taxes"

module Formatter
  class String < Base
    # Formats a list of Items into a human-readable receipt string.
    #
    # Each item line:   "<quantity> <name>: <total>"
    # Summary lines:    "Sales Taxes: <total_tax>"  and  "Total: <grand_total>"
    #
    # All monetary values are printed with exactly 2 decimal places.
    def call(items)
      taxes = Taxes.new(items)
      lines = items.map { |item| format_item(item, taxes) }
      lines << format("Sales Taxes: %.2f", taxes.total_taxes)
      lines << format("Total: %.2f", taxes.total)
      lines.join("\n")
    end

    private

    def format_item(item, taxes)
      label = item.imported? ? "imported #{item.name}" : item.name
      format("%d %s: %.2f", item.quantity, label, taxes.total_for(item))
    end
  end
end
