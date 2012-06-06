class Unfuddle
  class Configuration
    
    def initialize(instance)
      @instance = instance
    end
    
    
    [:subdomain, :username, :password].each do |attribute|
      module_eval <<-RUBY
        def #{attribute}(*arg)
          set_value :#{attribute}, arg.first if arg.any?
          get_value :#{attribute}
        end
        
        def #{attribute}=(value)
          set_value :#{attribute}, value
        end
      RUBY
    end
    
    
  private
    
    def set_value(attribute, value)
      @instance.instance_variable_set(:"@#{attribute}", value)
      @instance.instance_variable_set(:@http, nil)
    end
    
    def get_value(attribute)
      @instance.send(attribute)
    end
    
  end
end
