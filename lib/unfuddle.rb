require 'faraday'
require 'json'
require 'active_support/core_ext/benchmark'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/hash/indifferent_access'
require 'unfuddle/configuration'
require 'unfuddle/error'
require 'unfuddle/project'
require 'unfuddle/response'
require 'unfuddle/has_tickets'


class Unfuddle
  include HasTickets
  
  class << self
    
    def config(options=nil)
      configuration = Unfuddle::Configuration.new
      configuration.from_options(options) if options
      yield configuration if block_given?
      instance.configuration = configuration
    end
    
    def with_config(options)
      current_configuration = instance.configuration
      begin
        config(options)
        yield
      ensure
        instance.configuration = current_configuration
      end
    end
    
    def instance
      @unfuddle ||= self.new
    end
    
    def assert_response!(expected_response_code, response)
      unless response.status == expected_response_code
        raise InvalidResponseError.new(response)
      end
    end
    
    # Homemade `delegate`
    [:get, :post, :put, :delete, :configuration].each do |method|
      module_eval <<-RUBY
        def #{method}(*args, &block)
          instance.#{method}(*args, &block)
        end
      RUBY
    end
    
    [:subdomain, :username, :password, :logger, :include_associations?, :include_closed_on?].each do |method|
      module_eval <<-RUBY
        def #{method}
          configuration.#{method}
        end
      RUBY
    end
    
  end
  
  attr_reader :configuration
  
  def configuration=(configuration)
    @configuration = configuration
    @http = nil
  end
  
  [:subdomain, :username, :password, :logger, :include_associations?, :include_closed_on?].each do |method|
    module_eval <<-RUBY
      def #{method}
        configuration.#{method}
      end
    RUBY
  end
  
  
  
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
    response
  ensure
    message = "[unfuddle:#{method}]  #{path}"
    message << "\n  #{body}" if body
    message = '%s (%.1fms)' % [ message, ms ] if ms
    logger.info(message)
    
    url = http.url_prefix.to_s + path
    logger.warn "[unfuddle:#{method}] URL length exceeded 2000 characters" if url.length > 2000
  end
  
  def http_send(method, path, body, headers)
    response = http.public_send(method, path, body, headers)
    
    Response.new(response).tap do |response|
      raise ServerError.new(response) if response.server_error?
      raise UnauthorizedError.new(response) if response.unauthorized?
    end
    
  rescue Faraday::Error::ConnectionFailed
    raise ConnectionError, $!.message
  rescue Faraday::Error::TimeoutError, Errno::ETIMEDOUT
    raise TimeoutError, $!.message
  end
  
  def http
    raise ConfigurationError, "Unfuddle is not configured" unless configured?
    @http ||= Faraday.new("https://#{subdomain}.unfuddle.com", ssl: {verify: false}) do |faraday|
      faraday.adapter Faraday.default_adapter
      faraday.basic_auth username, password
    end
  end
  
end
