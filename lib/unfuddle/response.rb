require 'unfuddle/error'


class Unfuddle
  class Response
    
    
    def initialize(faraday_response)
      @faraday_response = faraday_response
    end
    
    def status
      faraday_response.status
    end
    
    def server_error?
      status == 500
    end
    
    def unauthorized?
      status == 401
    end
    
    def body
      faraday_response.body
    end
    
    def location
      faraday_response["location"]
    end
    
    def json
      @json ||= begin
        json = self.class.normalized_body(body)
        json.empty? ? {} : JSON.load(json)
      end
    end
    
    def self.normalized_body(body)
      body.gsub(/\u0000/, "").strip
    end
    
    
  private
    
    attr_reader :faraday_response
    
  end
end
