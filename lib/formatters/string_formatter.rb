require_relative "formatter"

module Formatter
  class String < Base
    # Formats a list of Items into a human-readable receipt string.
    #
    # Each item line:   "<quantity> <name>: <total>"
    # Summary lines:    "Sales Taxes: <total_tax>"  and  "Total: <grand_total>"
    #
    # All monetary values are printed with exactly 2 decimal places.
    def call(items)
      lines = items.map { |item| format_item(item) }
      lines << format("Sales Taxes: %.2f", total_taxes(items))
      lines << format("Total: %.2f", grand_total(items))
      lines.join("\n")
    end

    private

    def format_item(item)
      label = item.imported? ? "imported #{item.name}" : item.name
      format("%d %s: %.2f", item.quantity, label, item.total)
    end

    # Sum of all taxes (basic + import) across every unit of every item.
    #
    # Accumulates in integer cents via Item#tax_in_cents to prevent IEEE 754
    # drift, then converts once at the display boundary.
    def total_taxes(items)
      items.sum { |item| item.tax_in_cents * item.quantity } / 100.0
    end

    def grand_total(items)
      items.sum(&:total_in_cents) / 100.0
    end
  end
end
