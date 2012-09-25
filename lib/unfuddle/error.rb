class Unfuddle
  
  class ServerError < StandardError
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
  
end
