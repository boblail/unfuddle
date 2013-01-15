class Unfuddle
  class Response
    
    
    def initialize(faraday_response)
      @faraday_response = faraday_response
    end
    
    def status
      faraday_response.status
    end
    
    def json
      @json ||= JSON.load(faraday_response.body)
    end
    
    
  private
    
    attr_reader :faraday_response
    
  end
end
