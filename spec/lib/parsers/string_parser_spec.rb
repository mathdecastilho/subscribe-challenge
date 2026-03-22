require_relative "../../../lib/parsers/string_parser"

RSpec.describe Parser::String do
  subject(:parser) { described_class.new }

  describe "#call" do
    context "with a single non-imported item" do
      let(:items) { parser.call("1 music CD at 14.99") }

      it "returns an array with one Item" do
        expect(items).to contain_exactly(be_a(Item))
      end

      it "parses quantity" do
        expect(items.first.quantity).to eq(1)
      end

      it "parses name" do
        expect(items.first.name).to eq("music CD")
      end

      it "parses unit_price" do
        expect(items.first.unit_price).to eq(14.99)
      end

      it "sets imported to false" do
        expect(items.first.imported?).to be(false)
      end
    end

    context "with a single imported item" do
      let(:items) { parser.call("2 imported books at 12.49") }

      it "parses quantity" do
        expect(items.first.quantity).to eq(2)
      end

      it "parses name without the word 'imported'" do
        expect(items.first.name).to eq("books")
      end

      it "parses unit_price" do
        expect(items.first.unit_price).to eq(12.49)
      end

      it "sets imported to true" do
        expect(items.first.imported?).to be(true)
      end
    end

    context "with multiple lines" do
      let(:input) do
        "1 music CD at 14.99\n2 imported books at 12.49\n1 bottle of perfume at 47.50"
      end

      it "returns one Item per line" do
        expect(parser.call(input).length).to eq(3)
      end

      it "returns an array of Items" do
        expect(parser.call(input)).to all(be_a(Item))
      end

      it "parses each line correctly" do
        items = parser.call(input)
        expect(items[0].name).to eq("music CD")
        expect(items[1].name).to eq("books")
        expect(items[2].name).to eq("bottle of perfume")
      end
    end

    context "with an invalid line" do
      it "raises ArgumentError" do
        expect { parser.call("not a valid line") }.to raise_error(ArgumentError)
      end
    end
  end
end
