class Unfuddle
  class Configuration
    
    
    [:subdomain, :username, :password, :logger, :include_associations, :include_closed_on, :timeout].each do |attribute|
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
    alias :include_closed_on? :include_closed_on
    
    
    def merge(options)
      to_h.merge(options)
    end
    
    def to_h
      { subdomain: subdomain,
        username: username,
        password: password,
        include_associations: include_associations,
        include_closed_on: include_closed_on,
        logged: logger,
        timeout: timeout }
    end
    
    def from_options(options)
      options = options.with_indifferent_access
      self.subdomain             = options[:subdomain]             if options.key?(:subdomain)
      self.username              = options[:username]              if options.key?(:username)
      self.password              = options[:password]              if options.key?(:password)
      self.include_associations  = options[:include_associations]  if options.key?(:include_associations)
      self.include_closed_on     = options[:include_closed_on]     if options.key?(:include_closed_on)
      self.timeout               = options.fetch :timeout, 120
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
