require_relative "../../../lib/formatters/formatter"

RSpec.describe Formatter::Base do
  subject(:formatter) { described_class.new }

  describe "#call" do
    it "raises NotImplementedError" do
      expect { formatter.call([], nil) }.to raise_error(NotImplementedError)
    end
  end
end
