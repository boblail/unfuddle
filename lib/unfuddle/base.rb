require 'unfuddle'
require 'active_support/inflector'
require 'active_support/core_ext/hash'


class Unfuddle
  class Base
    
    def initialize(attributes)
      __set_attributes(attributes)
    end
    
    def unfetched?
      @attributes.keys == %w{id}
    end
    
    def id
      @attributes["id"]
    end
    
    def __set_attributes(attributes)
      # raise ArgumentError, "attributes is expected to be a hash. It should not be nil" if attributes.nil?
      raise ArgumentError, "attributes is expected to be a hash. It should not be :invalid" if attributes == :invalid
      raise ArgumentError, "attributes is expected to be a hash, but it was #{attributes.class} instead" unless attributes.is_a?(Hash)
      @attributes = attributes
    end
    
    
    
    # Respond to attributes
    
    def attributes
      _attributes.dup
    end
    
    def invalid?
      _attributes == :invalid
    end
    
    def method_missing(method_name, *args, &block)
      if !invalid? && _attributes.key?(method_name.to_s)
        _attributes[method_name.to_s]
      else
        super(method_name, *args, &block)
      end
    end
    
    def respond_to?(method_name)
      if super(method_name)
        true
      else
        _attributes.key?(method_name.to_s)
      end
    end
    
    def write_attribute(attribute, value)
      _attributes[attribute] = value
    end
    
    def update_attributes!(attributes)
      attributes.each do |key, value|
        write_attribute(key, value)
      end
      save!
    end
    
    def update_attribute(attribute, value)
      write_attribute(attribute, value)
      save!
    end
    
    
    
    # Finders
    
    class << self
      
      def find_by(*attributes)
        attributes.each do |attribute|
          instance_eval <<-RUBY
            def find_by_#{attribute}(value)
              all.find { |instance| instance.#{attribute} == value }
            end
          RUBY
        end
      end
      
    end
    
    
    
    # Has many
    
    class << self
      
      def has_many(collection_name, options={})
        collection_name = collection_name.to_s
        path = collection_name
        individual_name = collection_name.singularize
        class_name = options.fetch(:class_name, individual_name.classify)
        
        require "unfuddle/#{individual_name}"
        
        class_eval <<-RUBY
          def #{collection_name}
            @#{collection_name} ||= get('#{path}')[1].map { |attributes| #{class_name}.new(attributes) }
          end
          
          def #{individual_name}(id)
            response = get("#{path}/\#{id}")
            return nil if response[1] == :invalid
            #{class_name}.new response[1]
          end
          
          def new_#{individual_name}(attributes)
            #{class_name}.new(attributes)
          end
          
          def create_#{individual_name}(params)
            instance = #{class_name}.new(params)
            attributes = post('#{path}', instance)[1]
            unless attributes == :invalid
              instance.__set_attributes(attributes)
              @#{collection_name}.push(instance) if @#{collection_name}
              instance
            else
              nil
            end
          end
        RUBY
      end
      
    end
    
    
    
    # Nest Unfuddle requests
    
    def relative_path
      raise NotImplementedError
    end
    
    [:get, :post, :put, :delete].each do |method|
      module_eval <<-RUBY
        def #{method}(path, *args)
          Unfuddle.#{method}(relative_path + "/" + path, *args)
        end
      RUBY
    end
    
    
    
    # Serialization
    
    def to_params
      attributes
    end
    
    def singular_name
      self.class.name[/[^:]*$/].tableize.singularize
    end
    
    def to_xml
      to_params.to_xml(root: singular_name)
    end
    
    def to_json
      JSON.dump({singular_name => to_params})
    end
    
    def fetch!
      response = get("")
      Unfuddle.assert_response!(200, response)
      __set_attributes(response[1])
    
    rescue InvalidResponseError
      binding.pry if binding.respond_to?(:pry)
      raise $!
    end
    
    def save!
      put "", self
    end
    
    def destroy!
      delete ""
    end
    
    
    
  private
    
    def _attributes
      fetch! if unfetched?
      @attributes
    end
    
  end
end
