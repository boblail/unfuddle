require 'unfuddle/base'

class Unfuddle
  class TicketReport < Base
    
    def relative_path
      "projects/#{parent_id}/ticket_reports/#{id}"
    end
    
  end
end
