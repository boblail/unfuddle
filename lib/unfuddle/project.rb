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
    
    
    
  end
end
