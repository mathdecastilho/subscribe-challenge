module Formatter
  class Base
    def call(_items)
      raise NotImplementedError, "#{self.class}#call is not implemented"
    end
  end
end
