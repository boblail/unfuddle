require 'unfuddle/base'


class Unfuddle
  class Person < Base
    
    def relative_path
      "people/#{id}"
    end
    
  end
end
