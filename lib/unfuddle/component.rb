require 'unfuddle/base'

class Unfuddle
  class Component < Base
    
    def relative_path
      "projects/#{project_id}/components/#{id}"
    end
    
  end
end
