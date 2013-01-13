require 'faraday'
require 'json'
require 'active_support/core_ext/benchmark'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/hash/indifferent_access'
require 'unfuddle/configuration'
require 'unfuddle/error'
require 'unfuddle/project'
require 'unfuddle/has_tickets'


class Unfuddle
  include HasTickets
  
  class << self
    
    def config(*args)
      configuration = Unfuddle::Configuration.new(instance)
      if args.first.is_a?(Hash)
        options = args.first.with_indifferent_access
        configuration.subdomain = options[:subdomain] if options.key?(:subdomain)
        configuration.username  = options[:username]  if options.key?(:username)
        configuration.password  = options[:password]  if options.key?(:password)
      end
      yield configuration if block_given?
      configuration
    end
    
    def instance
      @unfuddle ||= self.new
    end
    
    def assert_response!(expected_response_code, response)
      unless response[0] == expected_response_code
        raise InvalidResponseError.new(response)
      end
    end
    
    # Homemade `delegate`
    [:get, :post, :put, :delete].each do |method|
      module_eval <<-RUBY
        def #{method}(*args, &block)
          instance.#{method}(*args, &block)
        end
      RUBY
    end
    
  end
  
  attr_reader :subdomain,
              :username,
              :password
  
  
  
  def project(project_id)
    Unfuddle::Project.new("id" => project_id)
  end
  
  
  
  def get(path)
    http_send_with_logging :get, path
  end
  
  def post(path, object)
    http_send_with_logging :post, path, object.to_xml
  end
  
  def put(path, object)
    http_send_with_logging :put, path, object.to_xml
  end
  
  def delete(path)
    http_send_with_logging :delete, path
  end
  
  
  
  def configured?
    subdomain && username && password
  end
  
  
  
protected
  
  def http_send_with_logging(method, path, body=nil, headers={})
    path = "/api/v1/#{path}"
    headers = headers.merge({ # read JSON, write XML
      "Accept" => "application/json",
      "Content-type" => "application/xml" })
    
    response = nil
    ms = Benchmark.ms do
      response =  http_send(method, path, body, headers)
    end
    
    message = "[unfuddle:#{method}]  #{path}"
    message << "\n  #{body}" if body
    puts ('%s (%.1fms)' % [ message, ms ])
    
    response
  end
  
  def http_send(method, path, body, headers)
    response = http.public_send(method, path, body, headers)
    
    code = response.status
    raise ServerError.new(request) if code == 500
    raise UnauthorizedError.new(request) if code == 401
    
    json = JSON.load(response.body) rescue :invalid
    
    [code, json]
    
  rescue Faraday::Error::ConnectionFailed
    raise ConnectionError
  end
  
  def http
    raise "Unfuddle is not configured" unless configured?
    @http ||= Faraday.new("https://#{@subdomain}.unfuddle.com", ssl: {verify: false}) do |faraday|
      faraday.adapter Faraday.default_adapter
      faraday.basic_auth @username, @password
    end
  end
  
end
