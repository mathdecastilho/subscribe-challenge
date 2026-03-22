require_relative "../app"

RSpec.describe App do
  subject(:app) { described_class.new }

  describe "#call" do
    let(:input) { "1 music CD at 14.99\n2 imported books at 12.49" }

    it "returns a formatted receipt string" do
      expect(app.call(input)).to be_a(String)
    end

    it "includes a line per item, sales taxes, and total" do
      # music CD: basic tax ceil(149.9/5)*5=150 cents=1.50; total=16.49
      # 2 imported books: import tax ceil(62.45/5)*5=65 cents=0.65; total=(1249+65)*2/100=26.28
      # Sales Taxes: 1.50*1 + 0.65*2 = 2.80
      # Total: 16.49 + 26.28 = 42.77
      expected = <<~RECEIPT.chomp
        1 music CD: 16.49
        2 books: 26.28
        Sales Taxes: 2.80
        Total: 42.77
      RECEIPT
      expect(app.call(input)).to eq(expected)
    end
  end
end
