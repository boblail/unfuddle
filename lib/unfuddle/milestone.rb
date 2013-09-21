require 'unfuddle/base'

class Unfuddle
  class Milestone < Base
    
    def relative_path
      "projects/#{project_id}/milestones/#{id}"
    end
    
  end
end
