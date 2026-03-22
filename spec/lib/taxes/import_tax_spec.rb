require_relative "../../../lib/item"
require_relative "../../../lib/taxes/import_tax"

RSpec.describe ImportTax do
  def item(name:, unit_price:, imported:)
    Item.new(quantity: 1, imported: imported, name: name, unit_price: unit_price)
  end

  subject(:handler) { described_class.new }

  describe "#tax_in_cents_for" do
    context "when item is imported" do
      it "returns 5% of unit_price rounded up to nearest 5 cents" do
        # 4750 * 5 / 100.0 = 237.5 → ceil(237.5/5)*5 = ceil(47.5)*5 = 48*5 = 240
        expect(handler.tax_in_cents_for(item(name: "bottle of perfume", unit_price: 47.50, imported: true))).to eq(240)
      end

      it "rounds a fractional result up to the nearest 5 cents" do
        # 1249 * 5 / 100.0 = 62.45 → ceil(62.45/5)*5 = ceil(12.49)*5 = 13*5 = 65
        expect(handler.tax_in_cents_for(item(name: "book", unit_price: 12.49, imported: true))).to eq(65)
      end

      it "returns an Integer" do
        expect(handler.tax_in_cents_for(item(name: "book", unit_price: 12.49, imported: true))).to be_a(Integer)
      end

      it "is not affected by item quantity" do
        item_qty1 = Item.new(quantity: 1, imported: true, name: "book", unit_price: 12.49)
        item_qty3 = Item.new(quantity: 3, imported: true, name: "book", unit_price: 12.49)
        expect(handler.tax_in_cents_for(item_qty1)).to eq(handler.tax_in_cents_for(item_qty3))
      end

      it "applies regardless of category (books are still taxed on import)" do
        expect(handler.tax_in_cents_for(item(name: "book", unit_price: 12.49, imported: true))).to eq(65)
      end
    end

    context "when item is not imported" do
      it "returns 0" do
        expect(handler.tax_in_cents_for(item(name: "music CD", unit_price: 14.99, imported: false))).to eq(0)
      end

      it "returns 0 even for a taxable category" do
        expect(handler.tax_in_cents_for(item(name: "bottle of perfume", unit_price: 47.50, imported: false))).to eq(0)
      end
    end

    context "with a next handler in the chain" do
      it "adds the next handler's result to its own" do
        next_handler = instance_double("BasicTax", tax_in_cents_for: 150)
        chained = described_class.new(next_handler: next_handler)
        # bottle of perfume import: 240, next handler: 150 → total: 390
        expect(chained.tax_in_cents_for(item(name: "bottle of perfume", unit_price: 47.50, imported: true))).to eq(390)
      end

      it "still returns 0 for domestic items but adds next handler's result" do
        next_handler = instance_double("BasicTax", tax_in_cents_for: 150)
        chained = described_class.new(next_handler: next_handler)
        # domestic music CD: import=0, basic=150 → total: 150
        expect(chained.tax_in_cents_for(item(name: "music CD", unit_price: 14.99, imported: false))).to eq(150)
      end
    end
  end
end
