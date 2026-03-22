require_relative "../../../lib/item"
require_relative "../../../lib/taxes/basic_tax"

RSpec.describe BasicTax do
  # Helper: build a minimal item double with the given properties.
  def item(name:, unit_price:, imported: false)
    Item.new(quantity: 1, imported: imported, name: name, unit_price: unit_price)
  end

  subject(:handler) { described_class.new }

  describe "#tax_in_cents_for" do
    context "when category is :other (taxable)" do
      it "returns 10% of unit_price rounded up to nearest 5 cents" do
        # 1499 * 10 / 100.0 = 149.9 → ceil(149.9/5)*5 = ceil(29.98)*5 = 30*5 = 150
        expect(handler.tax_in_cents_for(item(name: "music CD", unit_price: 14.99))).to eq(150)
      end

      it "returns an Integer" do
        expect(handler.tax_in_cents_for(item(name: "music CD", unit_price: 14.99))).to be_a(Integer)
      end

      it "is not affected by item quantity" do
        item_qty1 = Item.new(quantity: 1, imported: false, name: "music CD", unit_price: 14.99)
        item_qty3 = Item.new(quantity: 3, imported: false, name: "music CD", unit_price: 14.99)
        expect(handler.tax_in_cents_for(item_qty1)).to eq(handler.tax_in_cents_for(item_qty3))
      end
    end

    context "when category is :book (exempt)" do
      it "returns 0" do
        expect(handler.tax_in_cents_for(item(name: "book", unit_price: 12.49))).to eq(0)
      end
    end

    context "when category is :food (exempt)" do
      it "returns 0 for a chocolate bar" do
        expect(handler.tax_in_cents_for(item(name: "chocolate bar", unit_price: 0.85))).to eq(0)
      end

      it "returns 0 for a box of chocolates" do
        expect(handler.tax_in_cents_for(item(name: "box of chocolates", unit_price: 10.00))).to eq(0)
      end
    end

    context "when category is :medical (exempt)" do
      it "returns 0 for headache pills" do
        expect(handler.tax_in_cents_for(item(name: "packet of headache pills", unit_price: 9.75))).to eq(0)
      end
    end

    context "with a next handler in the chain" do
      it "adds the next handler's result to its own" do
        next_handler = instance_double("ImportTax", tax_in_cents_for: 240)
        chained = described_class.new(next_handler: next_handler)
        # music CD basic: 150, next handler: 240 → total: 390
        expect(chained.tax_in_cents_for(item(name: "music CD", unit_price: 14.99))).to eq(390)
      end

      it "still passes 0 for exempt items but adds next handler's result" do
        next_handler = instance_double("ImportTax", tax_in_cents_for: 65)
        chained = described_class.new(next_handler: next_handler)
        # book: exempt (0) + next (65) = 65
        expect(chained.tax_in_cents_for(item(name: "book", unit_price: 12.49))).to eq(65)
      end
    end
  end
end
