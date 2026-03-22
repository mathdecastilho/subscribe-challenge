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
    # Accumulates in integer cents to prevent IEEE 754 drift across many items,
    # then converts once at the display boundary.
    def total_taxes(items)
      total_cents = items.sum { |item| (tax_in_cents(item)) * item.quantity }
      total_cents / 100.0
    end

    def grand_total(items)
      total_cents = items.sum { |item| total_in_cents(item) }
      total_cents / 100.0
    end

    # Returns the combined per-unit tax for one item in integer cents.
    def tax_in_cents(item)
      (item.basic_tax * 100).round + (item.import_tax * 100).round
    end

    # Returns the total price for one item line in integer cents.
    def total_in_cents(item)
      (item.total * 100).round
    end
  end
end
