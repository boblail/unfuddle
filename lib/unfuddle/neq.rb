class Unfuddle
  module NeqHelper
    
    def neq(arg)
      Neq.new(arg)
    end
    
  end
  
  class Neq
    
    def initialize(value)
      @value = value
    end
    
    def to_s
      "neq(#{value.inspect})"
    end
    
    attr_reader :value
    
  end
end
  