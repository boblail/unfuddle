class Unfuddle
  
  module Error
  end
  
  class ConnectionError < StandardError
    include ::Unfuddle::Error
  end
  
  
  
  class InvalidResponseError < StandardError
    include ::Unfuddle::Error
    
    def initialize(response)
      @response = response
    end
    
    attr_reader :response
  end
  
  class ServerError < InvalidResponseError
  end
  
  class UnauthorizedError < InvalidResponseError
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
