require 'unfuddle/base'
require 'unfuddle/has_tickets'


class Unfuddle
  class Project < Base
    include HasTickets
    
    def self.all
      @projects ||= begin
        response = Unfuddle.get('projects')
        
        if response.status == 404
          nil
        else
          Unfuddle.assert_response!(200, response)
          response.json.map { |attributes| self.new(attributes) }
        end
      end
    end
    
    def self.fetch(id)
      response = Unfuddle.get("projects/#{id}")
      
      if response.status == 404
        nil
      else
        Unfuddle.assert_response!(200, response)
        self.new response.json
      end
    end
    
    def relative_path
      "projects/#{id}"
    end
    
    
    
    find_by :title
    
    has_many :custom_field_values
    has_many :severities
    has_many :components
    has_many :ticket_reports
    has_many :tickets
    has_many :milestones
    
    
    
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
    
    def number_of_custom_field_named!(name)
      number_of_custom_field_named(name) || (raise UndefinedCustomField, "A custom field named \"#{name}\" is not defined!")
    end
    
    def number_of_custom_field_named(name)
      custom_fields.key(name)
    end
    
    
    
    def find_custom_field_value_by_value!(field, value)
      n = number_of_custom_field_named!(field)
      result = custom_field_values.find { |cfv| cfv.field_number == n && cfv.value == value }
      raise UndefinedCustomFieldValue, "\"#{value}\" is not a value for the custom field \"#{field}\"!" unless result
      result
    end
    
    def find_custom_field_value_by_id!(field, id)
      n = number_of_custom_field_named!(field)
      result = custom_field_values.find { |cfv| cfv.field_number == n && cfv.id == id }
      raise UndefinedCustomFieldValue, "\"#{id}\" is not the id of a value for the custom field \"#{field}\"!" unless result
      result
    end
    
    
    
    def find_severity_by_name!(name)
      find_severity_by_name(name) || (raise UndefinedSeverity, "A severity named \"#{name}\" is not defined!")
    end
    
    def find_severity_by_name(name)
      severities.find { |severity| severity.name == name }
    end
    
    
    
    def prepare_key_and_value_for_conditions_string(key, value)
      key, value = super
      
      # If the value is the name of a severity, try to look it up
      value = find_severity_by_name!(value).id if key == :severity && value.is_a?(String)
      
      # If the key is a custom field, look up the key and value
      if key.is_a?(String)
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
