require 'unfuddle/base'
require 'active_support/core_ext/array/wrap'


class Unfuddle
  class Project < Base
    
    def self.all
      @projects ||= Unfuddle.get('projects')[1].map { |attributes| self.new(attributes) }
    end
    
    def self.fetch(id)
      self.new Unfuddle.get("projects/#{id}")[1]
    end
    
    def relative_path
      "projects/#{id}/"
    end
    
    
    
    find_by :title
    
    has_many :custom_field_values
    has_many :severities
    has_many :ticket_reports
    has_many :tickets
    
    
    
    def custom_fields
      { 1 => ticket_field1_active ? ticket_field1_title : nil,
        2 => ticket_field2_active ? ticket_field2_title : nil,
        3 => ticket_field3_active ? ticket_field3_title : nil }
    end
    
    def custom_fields_defined
      custom_fields.values.compact
    end
    
    def custom_field_defined?(field_title)
      custom_fields_defined.member?(field_title)
    end
    
    def first_available_custom_field
      (1..3).find { |n| custom_fields[n].nil? }
    end
    
    def number_of_custom_field_named(name)
      custom_fields.key(name)
    end
    
    def number_of_custom_field_named!(name)
      number_of_custom_field_named(name) || (raise ArgumentError, "A custom field named \"#{name}\" is not defined!")
    end
    
    
    
    def find_severity_by_name!(name)
      severity = severities.find { |severity| severity.name == name }
      severity || (raise ArgumentError, "A severity named \"#{name}\" is not defined!")
    end
    
    def find_custom_field_value_by_value!(field, value)
      n = number_of_custom_field_named!(field)
      result = custom_field_values.find { |cfv| cfv.field_number == n && cfv.value == value }
      raise ArgumentError, "\"#{value}\" is not a value for the custom field \"#{field}\"!" unless result
      result
    end
    
    def find_custom_field_value_by_id!(field, id)
      n = number_of_custom_field_named!(field)
      result = custom_field_values.find { |cfv| cfv.field_number == n && cfv.id == id }
      raise ArgumentError, "\"#{id}\" is not the id of a value for the custom field \"#{field}\"!" unless result
      result
    end
    
    
    
    def find_tickets!(*conditions)
      raise ArgumentError.new("No conditions supplied: that's probably not good") if conditions.none?
      path = "ticket_reports/dynamic.json"
      path << "?conditions_string=#{construct_ticket_query(*conditions)}"
      response = get(path)
      
      assert_response!(200, response)
      
      ticket_report = response[1]
      group0 = ticket_report.fetch("groups", [])[0] || {}
      group0.fetch("tickets", [])
    end
    
    def find_tickets(*args)
      puts "Unfuddle::Project#find_tickets! is deprecated"
      find_tickets!(*args)
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
      
      # If the value is the name of a severity, try to look it up
      value = find_severity_by_name!(value).id if key.to_s == "severity" && value.is_a?(String)
      
      # If the key is a custom field, look up the key and value
      if key.is_a?(String) && custom_field_defined?(key)
        value = find_custom_field_value_by_value!(key, value).id unless value.is_a?(Fixnum)
        key = get_key_for_custom_field_named!(key)
      end
      
      [key, value]
    end
    
    def get_key_for_custom_field_named!(name)
      "field_#{number_of_custom_field_named!(name)}"
    end
    
    def get_ticket_attribute_for_custom_value_named!(name)
      "field#{number_of_custom_field_named!(name)}_value_id"
    end
    
    
    
  end
end
