require_relative "../../../lib/item"
require_relative "../../../lib/taxes/taxes"

RSpec.describe Taxes do
  def make_item(name:, unit_price:, imported:, quantity: 1)
    Item.new(quantity: quantity, imported: imported, name: name, unit_price: unit_price)
  end

  describe "#tax_in_cents_for" do
    it "returns an Integer" do
      item = make_item(name: "music CD", unit_price: 14.99, imported: false)
      expect(described_class.new([item]).tax_in_cents_for(item)).to be_a(Integer)
    end

    it "returns only basic tax for a domestic taxable item" do
      # music CD: basic=150, import=0
      item = make_item(name: "music CD", unit_price: 14.99, imported: false)
      expect(described_class.new([item]).tax_in_cents_for(item)).to eq(150)
    end

    it "returns only import tax for an exempt imported item" do
      # book: basic=0, import=65
      item = make_item(name: "book", unit_price: 12.49, imported: true)
      expect(described_class.new([item]).tax_in_cents_for(item)).to eq(65)
    end

    it "returns both basic and import tax for a taxable imported item" do
      # bottle of perfume: basic=475, import=240
      item = make_item(name: "bottle of perfume", unit_price: 47.50, imported: true)
      expect(described_class.new([item]).tax_in_cents_for(item)).to eq(715)
    end

    it "returns 0 for a domestic exempt item" do
      item = make_item(name: "chocolate bar", unit_price: 0.85, imported: false)
      expect(described_class.new([item]).tax_in_cents_for(item)).to eq(0)
    end

    it "is not affected by item quantity" do
      item_qty1 = Item.new(quantity: 1, imported: true, name: "bottle of perfume", unit_price: 47.50)
      item_qty3 = Item.new(quantity: 3, imported: true, name: "bottle of perfume", unit_price: 47.50)
      taxes_qty1 = described_class.new([item_qty1])
      taxes_qty3 = described_class.new([item_qty3])
      expect(taxes_qty1.tax_in_cents_for(item_qty1)).to eq(taxes_qty3.tax_in_cents_for(item_qty3))
    end
  end

  describe "#total_for" do
    it "returns the correct total for a domestic taxable item including basic tax" do
      # 14.99 + 1.50 = 16.49
      item = make_item(name: "music CD", unit_price: 14.99, imported: false)
      expect(described_class.new([item]).total_for(item)).to eq(16.49)
    end

    it "returns unit_price * quantity for an exempt item (no taxes)" do
      # 12.49 * 2 = 24.98
      item = make_item(name: "book", unit_price: 12.49, imported: false, quantity: 2)
      expect(described_class.new([item]).total_for(item)).to eq(24.98)
    end

    it "includes both basic and import tax for an imported taxable item" do
      # (4750 + 475 + 240) * 1 / 100.0 = 54.65
      item = make_item(name: "bottle of perfume", unit_price: 47.50, imported: true)
      expect(described_class.new([item]).total_for(item)).to eq(54.65)
    end

    it "includes only import tax for an exempt imported item" do
      # (1249 + 65) * 2 / 100.0 = 26.28
      item = make_item(name: "book", unit_price: 12.49, imported: true, quantity: 2)
      expect(described_class.new([item]).total_for(item)).to eq(26.28)
    end

    it "scales with quantity" do
      # imported box of chocolates: exempt from basic; import=50c; (1000+50)*3/100.0=31.50
      item = make_item(name: "box of chocolates", unit_price: 10.00, imported: true, quantity: 3)
      expect(described_class.new([item]).total_for(item)).to eq(31.50)
    end
  end

  describe "#total_taxes" do
    it "returns 0.0 when all items are exempt and domestic" do
      items = [
        make_item(name: "book",          unit_price: 12.49, imported: false),
        make_item(name: "chocolate bar", unit_price: 0.85,  imported: false)
      ]
      expect(described_class.new(items).total_taxes).to eq(0.0)
    end

    it "sums taxes across all items in the basket (input 1)" do
      # 2 books: 0; 1 music CD: 1.50; 1 chocolate bar: 0 → 1.50
      items = [
        make_item(name: "book",          unit_price: 12.49, imported: false, quantity: 2),
        make_item(name: "music CD",      unit_price: 14.99, imported: false),
        make_item(name: "chocolate bar", unit_price: 0.85,  imported: false)
      ]
      expect(described_class.new(items).total_taxes).to eq(1.50)
    end

    it "sums taxes across all items in the basket (input 2)" do
      # imported box of chocolates: import 50c; imported bottle of perfume: basic 475c + import 240c = 715c
      # (50 + 715) / 100.0 = 7.65
      items = [
        make_item(name: "box of chocolates",  unit_price: 10.00, imported: true),
        make_item(name: "bottle of perfume",  unit_price: 47.50, imported: true)
      ]
      expect(described_class.new(items).total_taxes).to eq(7.65)
    end

    it "accumulates in integer cents to avoid IEEE 754 drift (input 3)" do
      # imported bottle of perfume: basic 280c + import 140c = 420c
      # bottle of perfume: basic 190c
      # packet of headache pills: 0
      # 3 imported boxes of chocolates: import 60c/unit * 3 = 180c
      # total: (420 + 190 + 0 + 180) / 100.0 = 7.90
      items = [
        make_item(name: "bottle of perfume",        unit_price: 27.99, imported: true),
        make_item(name: "bottle of perfume",        unit_price: 18.99, imported: false),
        make_item(name: "packet of headache pills", unit_price:  9.75, imported: false),
        make_item(name: "boxes of chocolates",      unit_price: 11.25, imported: true, quantity: 3)
      ]
      expect(described_class.new(items).total_taxes).to eq(7.90)
    end
  end

  describe "#total" do
    it "returns the grand total for a simple basket (input 1)" do
      # 2 books: 24.98; 1 music CD: 16.49; 1 chocolate bar: 0.85 → 42.32
      items = [
        make_item(name: "book",          unit_price: 12.49, imported: false, quantity: 2),
        make_item(name: "music CD",      unit_price: 14.99, imported: false),
        make_item(name: "chocolate bar", unit_price: 0.85,  imported: false)
      ]
      expect(described_class.new(items).total).to eq(42.32)
    end

    it "returns the grand total for an imported basket (input 2)" do
      # imported box of chocolates: 10.50; imported bottle of perfume: 54.65 → 65.15
      items = [
        make_item(name: "box of chocolates", unit_price: 10.00, imported: true),
        make_item(name: "bottle of perfume", unit_price: 47.50, imported: true)
      ]
      expect(described_class.new(items).total).to eq(65.15)
    end

    it "returns the grand total for a mixed basket (input 3)" do
      # 32.19 + 20.89 + 9.75 + 35.55 = 98.38
      items = [
        make_item(name: "bottle of perfume",        unit_price: 27.99, imported: true),
        make_item(name: "bottle of perfume",        unit_price: 18.99, imported: false),
        make_item(name: "packet of headache pills", unit_price:  9.75, imported: false),
        make_item(name: "boxes of chocolates",      unit_price: 11.25, imported: true, quantity: 3)
      ]
      expect(described_class.new(items).total).to eq(98.38)
    end
  end
end
