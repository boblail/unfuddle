class Unfuddle
  class Configuration
    
    
    [:subdomain, :username, :password, :logger, :include_associations].each do |attribute|
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
    
    
    alias :include_associations? :include_associations
    
    
    def from_options(options)
      options = options.with_indifferent_access
      self.subdomain             = options[:subdomain]             if options.key?(:subdomain)
      self.username              = options[:username]              if options.key?(:username)
      self.password              = options[:password]              if options.key?(:password)
      self.include_associations  = options[:include_associations]  if options.key?(:include_associations)
      self.logger                = options.fetch :logger, Unfuddle::Configuration::Logger.new
    end
    
    
    class Logger
      def info(s)
        puts s
      end
    end
    
    
  private
    
    def set_value(attribute, value)
      instance_variable_set(:"@#{attribute}", value)
    end
    
    def get_value(attribute)
      instance_variable_get(:"@#{attribute}")
    end
    
  end
end
