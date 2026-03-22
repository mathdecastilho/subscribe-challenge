require_relative "../../../lib/parsers/parser"

RSpec.describe Parser::Base do
  subject(:parser) { described_class.new }

  describe "#call" do
    it "raises NotImplementedError" do
      expect { parser.call("anything") }.to raise_error(NotImplementedError)
    end
  end
end
