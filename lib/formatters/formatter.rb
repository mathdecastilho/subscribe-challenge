module Formatter
  class Base
    def call(_items, _taxes)
      raise NotImplementedError, "#{self.class}#call is not implemented"
    end
  end
end
