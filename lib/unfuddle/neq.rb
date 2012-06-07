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
    
    attr_reader :value
    
  end
end
  