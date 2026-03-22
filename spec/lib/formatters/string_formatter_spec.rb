require_relative "../../../lib/formatters/string_formatter"
require_relative "../../../lib/taxes/taxes"
require_relative "../../../lib/item"

RSpec.describe Formatter::String do
  subject(:formatter) { described_class.new }

  # Helper: build a Taxes instance for the given items.
  def taxes_for(items)
    Taxes.new(items)
  end

  describe "#call" do
    let(:items) do
      [
        Item.new(quantity: 2, imported: false, name: "book",          unit_price: 12.49),
        Item.new(quantity: 1, imported: false, name: "music CD",      unit_price: 14.99),
        Item.new(quantity: 1, imported: false, name: "chocolate bar", unit_price: 0.85)
      ]
    end

    let(:expected) do
      <<~TEXT.chomp
        2 book: 24.98
        1 music CD: 16.49
        1 chocolate bar: 0.85
        Sales Taxes: 1.50
        Total: 42.32
      TEXT
    end

    it "returns the correctly formatted receipt string" do
      expect(formatter.call(items, taxes_for(items))).to eq(expected)
    end

    it "formats each item line as '<quantity> <name>: <total>'" do
      lines = formatter.call(items, taxes_for(items)).split("\n")
      expect(lines[0]).to eq("2 book: 24.98")
      expect(lines[1]).to eq("1 music CD: 16.49")
      expect(lines[2]).to eq("1 chocolate bar: 0.85")
    end

    it "prints the total sales taxes with 2 decimal places" do
      lines = formatter.call(items, taxes_for(items)).split("\n")
      expect(lines[-2]).to eq("Sales Taxes: 1.50")
    end

    it "prints the grand total with 2 decimal places" do
      lines = formatter.call(items, taxes_for(items)).split("\n")
      expect(lines[-1]).to eq("Total: 42.32")
    end

    it "uses the taxes object passed in rather than computing its own" do
      fake_taxes = instance_double(Taxes,
        total_taxes: 0.0,
        total:       1.00,
        total_for:   1.00
      )
      item = Item.new(quantity: 1, imported: false, name: "music CD", unit_price: 14.99)
      expect(formatter.call([item], fake_taxes)).to include("Total: 1.00")
    end

    context "with an imported item" do
      let(:items) do
        [Item.new(quantity: 1, imported: true, name: "bottle of perfume", unit_price: 47.50)]
      end

      it "includes both basic and import tax in Sales Taxes" do
        # basic: ceil(475.0/5)*5=475 cents=4.75, import: ceil(237.5/5)*5=240 cents=2.40
        # Sales Taxes: 4.75 + 2.40 = 7.15
        lines = formatter.call(items, taxes_for(items)).split("\n")
        expect(lines[-2]).to eq("Sales Taxes: 7.15")
      end
    end

    context "with only tax-exempt items" do
      let(:items) do
        [Item.new(quantity: 1, imported: false, name: "packet of headache pills", unit_price: 9.75)]
      end

      it "shows Sales Taxes: 0.00" do
        lines = formatter.call(items, taxes_for(items)).split("\n")
        expect(lines[-2]).to eq("Sales Taxes: 0.00")
      end
    end

    context "float accumulation" do
      # These tests guard against IEEE 754 drift when summing per-item tax and
      # total floats across a basket. All per-unit tax amounts are multiples of
      # 5 cents but 0.05 and 0.10 are not exactly representable in binary
      # floating point, so summing several of them can produce values like
      # 7.899999999999999 instead of 7.9. Taxes accumulates in integer cents
      # and converts only once at the display boundary.

      it "prints the correct Sales Taxes when float summation would drift (Input 3)" do
        items = [
          Item.new(quantity: 1, imported: true,  name: "bottle of perfume",        unit_price: 27.99),
          Item.new(quantity: 1, imported: false, name: "bottle of perfume",        unit_price: 18.99),
          Item.new(quantity: 1, imported: false, name: "packet of headache pills", unit_price:  9.75),
          Item.new(quantity: 3, imported: true,  name: "boxes of chocolates",      unit_price: 11.25)
        ]
        lines = formatter.call(items, taxes_for(items)).split("\n")
        expect(lines[-2]).to eq("Sales Taxes: 7.90")
      end

      it "prints the correct Total when float summation would drift" do
        items = [
          Item.new(quantity: 1, imported: true,  name: "bottle of perfume",        unit_price: 27.99),
          Item.new(quantity: 1, imported: false, name: "bottle of perfume",        unit_price: 18.99),
          Item.new(quantity: 1, imported: false, name: "packet of headache pills", unit_price:  9.75),
          Item.new(quantity: 3, imported: true,  name: "boxes of chocolates",      unit_price: 11.25)
        ]
        lines = formatter.call(items, taxes_for(items)).split("\n")
        expect(lines[-1]).to eq("Total: 98.38")
      end

      it "accumulates Sales Taxes in integer cents, not floats" do
        items = [
          Item.new(quantity: 2, imported: true,  name: "box of chocolates", unit_price: 10.00),  # import: 0.50*2=1.00
          Item.new(quantity: 1, imported: false, name: "music CD",          unit_price: 14.99),  # basic:  1.50
          Item.new(quantity: 3, imported: true,  name: "bottle of perfume", unit_price: 47.50)   # basic+import: 7.15*3=21.45
        ]
        # True Sales Taxes: 1.00 + 1.50 + 21.45 = 23.95
        lines = formatter.call(items, taxes_for(items)).split("\n")
        expect(lines[-2]).to eq("Sales Taxes: 23.95")
      end
    end
  end
end
