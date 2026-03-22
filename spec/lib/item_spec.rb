require_relative "../../lib/item"

RSpec.describe Item do
  subject(:item) do
    described_class.new(quantity: 2, imported: true, name: "book", unit_price: 12.49)
  end

  it "exposes quantity" do
    expect(item.quantity).to eq(2)
  end

  it "exposes name" do
    expect(item.name).to eq("book")
  end

  it "exposes unit_price" do
    expect(item.unit_price).to eq(12.49)
  end

  it "exposes imported via imported?" do
    expect(item.imported?).to be(true)
  end

  context "when not imported" do
    subject(:item) do
      described_class.new(quantity: 1, imported: false, name: "music CD", unit_price: 14.99)
    end

    it "returns false for imported?" do
      expect(item.imported?).to be(false)
    end
  end

  describe "#import_tax" do
    context "when imported" do
      it "returns 5% of unit_price" do
        item = described_class.new(quantity: 1, imported: true, name: "bottle of perfume", unit_price: 47.50)
        expect(item.import_tax).to eq(2.38)
      end

      it "is not affected by quantity" do
        item_qty1 = described_class.new(quantity: 1, imported: true, name: "book", unit_price: 12.49)
        item_qty3 = described_class.new(quantity: 3, imported: true, name: "book", unit_price: 12.49)
        expect(item_qty1.import_tax).to eq(item_qty3.import_tax)
      end
    end

    context "when not imported" do
      it "returns 0.0" do
        item = described_class.new(quantity: 1, imported: false, name: "music CD", unit_price: 14.99)
        expect(item.import_tax).to eq(0.0)
      end
    end
  end

  describe "#total" do
    context "when not imported" do
      it "returns unit_price times quantity" do
        item = described_class.new(quantity: 2, imported: false, name: "book", unit_price: 12.49)
        expect(item.total).to eq(24.98)
      end

      it "returns unit_price when quantity is 1" do
        item = described_class.new(quantity: 1, imported: false, name: "music CD", unit_price: 14.99)
        expect(item.total).to eq(14.99)
      end

      it "handles prices susceptible to float rounding errors" do
        # 0.1 + 0.2 == 0.30000000000000004 in naive float arithmetic;
        # working in integer cents prevents this class of error.
        item = described_class.new(quantity: 3, imported: false, name: "chocolate bar", unit_price: 0.85)
        expect(item.total).to eq(2.55)
      end
    end

    context "when imported" do
      it "includes 5% import tax in the total" do
        # 47.50 * 5% = 2.375 -> rounds to 2.38 cents; (47.50 + 2.38) * 1 = 49.88
        item = described_class.new(quantity: 1, imported: true, name: "bottle of perfume", unit_price: 47.50)
        expect(item.total).to eq(49.88)
      end

      it "applies import tax per unit then multiplies by quantity" do
        # 12.49 * 5% = 0.6245 -> rounds to 62 cents = 0.62; (12.49 + 0.62) * 2 = 26.22
        item = described_class.new(quantity: 2, imported: true, name: "book", unit_price: 12.49)
        expect(item.total).to eq(26.22)
      end
    end

    it "returns a numeric value" do
      expect(item.total).to be_a(Numeric)
    end
  end
end
