require_relative "../app"

RSpec.describe App do
  subject(:app) { described_class.new }

  describe "#call" do
    let(:input) { "1 music CD at 14.99\n2 imported books at 12.49" }

    it "returns an array of Items" do
      expect(app.call(input)).to all(be_a(Item))
    end

    it "returns one item per line" do
      expect(app.call(input).length).to eq(2)
    end
  end
end
