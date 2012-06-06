require 'unfuddle/base'

class Unfuddle
  class CustomFieldValue < Base
    
    def relative_path
      "projects/#{project_id}/custom_field_values/#{id}"
    end
    
  end
end
