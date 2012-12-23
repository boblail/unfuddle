class Unfuddle
  
  class ServerError < StandardError
    def initialize(request)
      @request = request
    end
    
    attr_reader :request
  end
  
  class UnauthorizedError < StandardError
    def initialize(request)
      @request = request
    end
    
    attr_reader :request
  end
  
  class InvalidResponseError < StandardError
    def initialize(response)
      @response = response
    end
    
    attr_reader :response
  end
  
  
  class UndefinedCustomField < ArgumentError
  end
  
  class UndefinedCustomFieldValue < ArgumentError
  end
  
  class UndefinedSeverity < ArgumentError
  end
  
end
