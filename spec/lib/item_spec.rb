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

  describe "#basic_tax" do
    context "when category is :other" do
      it "returns 10% of unit_price" do
        item = described_class.new(quantity: 1, imported: false, name: "music CD", unit_price: 14.99)
        expect(item.basic_tax).to eq(1.50)
      end

      it "is not affected by quantity" do
        item_qty1 = described_class.new(quantity: 1, imported: false, name: "music CD", unit_price: 14.99)
        item_qty3 = described_class.new(quantity: 3, imported: false, name: "music CD", unit_price: 14.99)
        expect(item_qty1.basic_tax).to eq(item_qty3.basic_tax)
      end
    end

    context "when category is exempt" do
      it "returns 0.0 for a book" do
        item = described_class.new(quantity: 1, imported: false, name: "book", unit_price: 12.49)
        expect(item.basic_tax).to eq(0.0)
      end

      it "returns 0.0 for a food item" do
        item = described_class.new(quantity: 1, imported: false, name: "chocolate bar", unit_price: 0.85)
        expect(item.basic_tax).to eq(0.0)
      end

      it "returns 0.0 for a medical item" do
        item = described_class.new(quantity: 1, imported: false, name: "packet of headache pills", unit_price: 9.75)
        expect(item.basic_tax).to eq(0.0)
      end
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
      context "with a taxable item (:other category)" do
        it "includes 10% basic tax in the total" do
          # 14.99 * 10% = 1.499 -> rounds to 150 cents = 1.50; (14.99 + 1.50) * 1 = 16.49
          item = described_class.new(quantity: 1, imported: false, name: "music CD", unit_price: 14.99)
          expect(item.total).to eq(16.49)
        end
      end

      context "with an exempt item" do
        it "does not apply basic tax to a book" do
          # no basic tax; 12.49 * 2 = 24.98
          item = described_class.new(quantity: 2, imported: false, name: "book", unit_price: 12.49)
          expect(item.total).to eq(24.98)
        end

        it "does not apply basic tax to a food item" do
          # no basic tax; 0.85 * 3 = 2.55
          item = described_class.new(quantity: 3, imported: false, name: "chocolate bar", unit_price: 0.85)
          expect(item.total).to eq(2.55)
        end

        it "does not apply basic tax to a medical item" do
          # no basic tax; 9.75 * 1 = 9.75
          item = described_class.new(quantity: 1, imported: false, name: "packet of headache pills", unit_price: 9.75)
          expect(item.total).to eq(9.75)
        end
      end
    end

    context "when imported" do
      it "includes both basic tax and import tax for a taxable item" do
        # basic: (4750 * 10 / 100.0).round = 475 cents
        # import: (4750 * 5 / 100.0).round = 238 cents
        # total: (4750 + 475 + 238) * 1 / 100.0 = 54.63
        item = described_class.new(quantity: 1, imported: true, name: "bottle of perfume", unit_price: 47.50)
        expect(item.total).to eq(54.63)
      end

      it "includes only import tax for an exempt item" do
        # no basic tax; import: (1249 * 5 / 100.0).round = 62 cents
        # total: (1249 + 62) * 2 / 100.0 = 26.22
        item = described_class.new(quantity: 2, imported: true, name: "book", unit_price: 12.49)
        expect(item.total).to eq(26.22)
      end
    end

    it "returns a numeric value" do
      expect(item.total).to be_a(Numeric)
    end
  end
end
