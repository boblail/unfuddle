require 'unfuddle/base'

class Unfuddle
  class Ticket < Base
    
    def relative_path
      "projects/#{project_id}/tickets/#{id}"
    end
    
    has_many :comments
    
  end
end
