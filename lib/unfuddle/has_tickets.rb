require 'active_support/core_ext/array/wrap'


class Unfuddle
  module HasTickets
    
    def find_tickets!(*conditions)
      raise ArgumentError.new("No conditions supplied: that's probably not good") if conditions.none?
      path = "ticket_reports/dynamic.json"
      path << "?conditions_string=#{construct_ticket_query(*conditions)}"
      response = get(path)
      
      Unfuddle.assert_response!(200, response)
      
      ticket_report = response[1]
      group0 = ticket_report.fetch("groups", [])[0] || {}
      group0.fetch("tickets", [])
    end
    
    
    
    def construct_ticket_query(*conditions)
      options = conditions.extract_options!
      conditions.concat(options.map { |key, value| Array.wrap(value).map { |value| create_condition_string(key, value) }.join("|") })
      conditions.join("%2C")
    end
    
    def create_condition_string(key, value)
      comparison = "eq"
      comparison, value = "neq", value.value if value.is_a?(Neq)
      key, value = prepare_key_and_value_for_conditions_string(key, value)
      "#{key}-#{comparison}-#{value}"
    end
    
    def prepare_key_and_value_for_conditions_string(key, value)
      
      # If the value is an id, convert it to a number
      value = value.to_i if value.is_a?(String) && value =~ /^\d+$/
      
      [key, value]
    end
    
  end
  
end
