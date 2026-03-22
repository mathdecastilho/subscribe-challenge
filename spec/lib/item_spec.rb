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
end
