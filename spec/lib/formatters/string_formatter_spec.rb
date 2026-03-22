require_relative "../../../lib/formatters/string_formatter"
require_relative "../../../lib/item"

RSpec.describe Formatter::String do
  subject(:formatter) { described_class.new }

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
      expect(formatter.call(items)).to eq(expected)
    end

    it "formats each item line as '<quantity> <name>: <total>'" do
      lines = formatter.call(items).split("\n")
      expect(lines[0]).to eq("2 book: 24.98")
      expect(lines[1]).to eq("1 music CD: 16.49")
      expect(lines[2]).to eq("1 chocolate bar: 0.85")
    end

    it "prints the total sales taxes with 2 decimal places" do
      lines = formatter.call(items).split("\n")
      expect(lines[-2]).to eq("Sales Taxes: 1.50")
    end

    it "prints the grand total with 2 decimal places" do
      lines = formatter.call(items).split("\n")
      expect(lines[-1]).to eq("Total: 42.32")
    end

    context "with an imported item" do
      let(:items) do
        [Item.new(quantity: 1, imported: true, name: "bottle of perfume", unit_price: 47.50)]
      end

      it "includes both basic and import tax in Sales Taxes" do
        # basic: 4.75, import: 2.38 -> Sales Taxes: 7.13
        lines = formatter.call(items).split("\n")
        expect(lines[-2]).to eq("Sales Taxes: 7.13")
      end
    end

    context "with only tax-exempt items" do
      let(:items) do
        [Item.new(quantity: 1, imported: false, name: "packet of headache pills", unit_price: 9.75)]
      end

      it "shows Sales Taxes: 0.00" do
        lines = formatter.call(items).split("\n")
        expect(lines[-2]).to eq("Sales Taxes: 0.00")
      end
    end
  end
end
