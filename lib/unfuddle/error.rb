class Unfuddle
  
  module Error
  end
  
  class ConnectionError < StandardError
    include ::Unfuddle::Error
  end
  
  class ServerError < StandardError
    include ::Unfuddle::Error
    
    def initialize(request)
      @request = request
    end
    
    attr_reader :request
  end
  
  class UnauthorizedError < StandardError
    include ::Unfuddle::Error
    
    def initialize(request)
      @request = request
    end
    
    attr_reader :request
  end
  
  class InvalidResponseError < StandardError
    include ::Unfuddle::Error
    
    def initialize(response)
      @response = response
    end
    
    attr_reader :response
  end
  
  
  class UndefinedCustomField < ArgumentError
    include ::Unfuddle::Error
  end
  
  class UndefinedCustomFieldValue < ArgumentError
    include ::Unfuddle::Error
  end
  
  class UndefinedSeverity < ArgumentError
    include ::Unfuddle::Error
  end
  
end
