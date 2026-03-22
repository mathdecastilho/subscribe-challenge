module Parser
  class Base
    def call(_input)
      raise NotImplementedError, "#{self.class}#call is not implemented"
    end
  end
end
