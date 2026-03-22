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

  describe "#total" do
    it "returns unit_price times quantity" do
      item = described_class.new(quantity: 2, imported: false, name: "book", unit_price: 12.49)
      expect(item.total).to eq(24.98)
    end

    it "returns unit_price when quantity is 1" do
      item = described_class.new(quantity: 1, imported: false, name: "music CD", unit_price: 14.99)
      expect(item.total).to eq(14.99)
    end

    it "handles prices that are susceptible to float rounding errors" do
      # 0.1 + 0.2 == 0.30000000000000004 in naive float arithmetic;
      # working in integer cents prevents this class of error.
      item = described_class.new(quantity: 3, imported: false, name: "chocolate bar", unit_price: 0.85)
      expect(item.total).to eq(2.55)
    end

    it "returns a numeric value" do
      expect(item.total).to be_a(Numeric)
    end
  end
end
