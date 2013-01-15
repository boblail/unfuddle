class Unfuddle
  class Response
    
    
    def initialize(faraday_response)
      @faraday_response = faraday_response
    end
    
    def status
      faraday_response.status
    end
    
    def body
      faraday_response.body
    end
    
    def json
      @json ||= JSON.load(self.class.normalized_body(body))
    end
    
    def self.normalized_body(body)
      body.gsub(/\u0000/, "")
    end
    
    
  private
    
    attr_reader :faraday_response
    
  end
end
