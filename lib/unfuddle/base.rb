require 'unfuddle'
require 'active_support/inflector'


class Unfuddle
  class Base
    
    def initialize(attributes)
      @attributes = attributes
    end
    
    
    
    # Respond to attributes
    
    def attributes
      @attributes.dup
    end
    
    def method_missing(method_name, *args, &block)
      if @attributes.key?(method_name.to_s)
        @attributes[method_name.to_s]
      else
        super(method_name, *args, &block)
      end
    end
    
    def respond_to?(method_name)
      if @attributes.key?(method_name.to_s)
        true
      else
        super(method_name)
      end
    end
    
    def write_attribute(attribute, value)
      @attributes[attribute] = value
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
            response = get('#{path}/' + id)
            return nil if response[1] == :invalid
            #{class_name}.new response[1]
          end
          
          def create_#{individual_name}(params)
            instance = #{class_name}.new(params)
            attributes = post('#{path}', instance)[1]
            unless attributes == :invalid
              instance.instance_variable_set(:@attributes, attributes)
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
          Unfuddle.#{method}(relative_path + path, *args)
        end
      RUBY
    end
    
    
    
    # Serialization
    
    def to_params
      @attributes
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
    
    def save!
      put "", self
    end
    
    def destroy!
      delete ""
    end
    
    
    
  end
end
