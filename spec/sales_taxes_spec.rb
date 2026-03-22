require_relative "../sales_taxes"

RSpec.describe SalesTaxes do
  subject(:app) { described_class.new }

  describe "#call" do
    it "returns the input string unchanged" do
      expect(app.call("hello world")).to eq("hello world")
    end

    it "returns an empty string when given an empty string" do
      expect(app.call("")).to eq("")
    end

    it "preserves whitespace and special characters" do
      input = "  foo\tbar\n"
      expect(app.call(input)).to eq(input)
    end
  end
end
