require 'unfuddle/base'

class Unfuddle
  class Severity < Base
    
    def relative_path
      "projects/#{project_id}/severities/#{id}"
    end
    
  end
end
