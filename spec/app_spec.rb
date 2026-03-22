require_relative "../app"

RSpec.describe App do
  subject(:app) { described_class.new }

  describe "#call" do
    it "returns a formatted receipt string" do
      expect(app.call("1 music CD at 14.99")).to be_a(String)
    end

    context "input 1: domestic items with mixed tax categories" do
      let(:input) do
        <<~INPUT.chomp
          2 book at 12.49
          1 music CD at 14.99
          1 chocolate bar at 0.85
        INPUT
      end

      it "produces the correct receipt" do
        # 2 book: exempt; 12.49*2 = 24.98
        # 1 music CD: basic tax ceil(149.9/5)*5=150c=1.50; total=16.49
        # 1 chocolate bar: exempt; total=0.85
        # Sales Taxes: 1.50 | Total: 42.32
        expected = <<~RECEIPT.chomp
          2 book: 24.98
          1 music CD: 16.49
          1 chocolate bar: 0.85
          Sales Taxes: 1.50
          Total: 42.32
        RECEIPT
        expect(app.call(input)).to eq(expected)
      end
    end

    context "input 2: imported items with basic and import tax" do
      let(:input) do
        <<~INPUT.chomp
          1 imported box of chocolates at 10.00
          1 imported bottle of perfume at 47.50
        INPUT
      end

      it "produces the correct receipt" do
        # imported box of chocolates: exempt from basic; import ceil(50/5)*5=50c=0.50; total=10.50
        # imported bottle of perfume: basic ceil(475/5)*5=475c=4.75;
        #                             import ceil(237.5/5)*5=240c=2.40; total=54.65
        # Sales Taxes: 0.50+7.15=7.65 | Total: 65.15
        expected = <<~RECEIPT.chomp
          1 imported box of chocolates: 10.50
          1 imported bottle of perfume: 54.65
          Sales Taxes: 7.65
          Total: 65.15
        RECEIPT
        expect(app.call(input)).to eq(expected)
      end
    end

    context "input 3: mixed imported and domestic items across all categories" do
      let(:input) do
        <<~INPUT.chomp
          1 imported bottle of perfume at 27.99
          1 bottle of perfume at 18.99
          1 packet of headache pills at 9.75
          3 imported boxes of chocolates at 11.25
        INPUT
      end

      it "produces the correct receipt" do
        # imported bottle of perfume: basic ceil(279.9/5)*5=280c=2.80;
        #                             import ceil(139.95/5)*5=140c=1.40; total=32.19
        # bottle of perfume: basic ceil(189.9/5)*5=190c=1.90; total=20.89
        # packet of headache pills: exempt; total=9.75
        # 3 imported boxes of chocolates: exempt from basic;
        #                                 import ceil(56.25/5)*5=60c=0.60; total=(1125+60)*3/100=35.55
        # Sales Taxes: 4.20+1.90+0.00+1.80=7.90 | Total: 98.38
        expected = <<~RECEIPT.chomp
          1 imported bottle of perfume: 32.19
          1 bottle of perfume: 20.89
          1 packet of headache pills: 9.75
          3 imported boxes of chocolates: 35.55
          Sales Taxes: 7.90
          Total: 98.38
        RECEIPT
        expect(app.call(input)).to eq(expected)
      end
    end
  end
end
