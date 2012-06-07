require 'unfuddle/base'

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
    
    def number_of_custom_field_named(title)
      custom_fields.key(title)
    end
    
    
    
    def find_severity_by_name!(name)
      severity = severities.find { |severity| severity.name == value }
      severity || raise("A severity named \"#{value}\" is not defined!")
    end
    
    def find_custom_field_value_by_value!(field, value)
      n = number_of_custom_field_named(field)
      result = custom_field_values.find { |cfv| cfv.field_number == n && cfv.value == value }
      raise "A custom field value named \"#{value}\" is not defined!" unless result
      result
    end
    
    
    
    def find_tickets(*conditions)
      path = "ticket_reports/dynamic.json"
      params = create_conditions_string(*conditions)
      path << "?#{params}" if params
      response = get(path)
      raise "Invalid response" if response[1] == :invalid
      ticket_report = response[1]
      group0 = ticket_report.fetch("groups", [])[0] || {}
      group0.fetch("tickets", [])
    end
    
    def create_conditions_string(*conditions)
      options = conditions.extract_options!
      conditions.concat(options.map { |key, value|
        if value.is_a?(Array)
          value.map { |val| "#{key}-eq-#{val}" }.join("|")
        else
          "#{key}-eq-#{value}"
        end
      })
      "conditions_string=#{conditions.join("%2C")}"
    end
    
    
    
  end
end
