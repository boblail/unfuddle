require 'unfuddle/base'

class Unfuddle
  class Comment < Base
    
    def relative_path
      "projects/#{project_id}/tickets/#{parent_id}/comments/#{id}"
    end
    
    attr_accessor :project_id
    
  end
end
