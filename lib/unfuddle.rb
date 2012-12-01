require 'net/https'
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
      raise InvalidResponseError.new(response) unless response[0] == expected_response_code
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
    path = "/api/v1/#{path}"
    request = Net::HTTP::Get.new(path, {"Accept" => "application/json"})
    request.basic_auth @username, @password
    http_send_with_logging "[unfuddle:get]  #{path}", request
  end
  
  def post(path, object)
    path = "/api/v1/#{path}"
    xml = object.to_xml
    request = Net::HTTP::Post.new(path, {"Content-type" => "application/xml"})
    request.basic_auth @username, @password
    http_send_with_logging "[unfuddle:post]  #{path}\n  #{xml}", request, xml
  end
  
  def put(path, object)
    xml = object.to_xml
    path = "/api/v1/#{path}"
    request = Net::HTTP::Put.new(path, {"Content-type" => "application/xml"})
    request.basic_auth @username, @password
    http_send_with_logging "[unfuddle:put]  #{path}\n  #{xml}", request, xml
  end
  
  def delete(path)
    path = "/api/v1/#{path}"
    request = Net::HTTP::Delete.new(path, {"Accept" => "application/json"})
    request.basic_auth @username, @password
    http_send_with_logging "[unfuddle:delete]  #{path}", request
  end
  
  
  
  def configured?
    subdomain && username && password
  end
  
  
  
protected
  
  def http_send_with_logging(message, request, *args)
    response = nil
    ms = Benchmark.ms { response =  http_send(request, *args) }
    puts ('%s (%.1fms)' % [ message, ms ])
    response
  end
  
  def http_send(request, *args)
    response = http.request(request, *args)
    json = JSON.load(response.body) rescue :invalid
    code = response.code.to_i
    
    raise ServerError.new(request) if code == 500
    
    [code, json]
  end
  
  def http
    raise "Unfuddle is not configured" unless configured?
    @http ||= Net::HTTP.new("#{@subdomain}.unfuddle.com", 443).tap do |http|
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
  end
  
end
