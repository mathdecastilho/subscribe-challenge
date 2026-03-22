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

  describe "#category" do
    {
      "book"                      => :book,
      "books"                     => :book,
      "box of chocolates"         => :food,
      "boxes of chocolates"       => :food,
      "chocolate bar"             => :food,
      "chocolate bars"            => :food,
      "packet of headache pills"  => :medical,
      "packets of headache pills" => :medical,
      "music CD"                  => :other,
      "bottle of perfume"         => :other
    }.each do |product_name, expected_category|
      it "categorises '#{product_name}' as :#{expected_category}" do
        item = described_class.new(quantity: 1, imported: false, name: product_name, unit_price: 1.00)
        expect(item.category).to eq(expected_category)
      end
    end
  end
end
