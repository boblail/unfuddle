require 'unfuddle/base'


class Unfuddle
  class Person < Base
    
    def self.all(options={})
      url = options[:including_removed] == true ? "people.json?removed=true" : "people.json"
      response = Unfuddle.get(url)
      
      if response.status == 404
        nil
      else
        Unfuddle.assert_response!(200, response)
        response.json.map { |attributes| self.new(attributes) }
      end
    end
    
    def relative_path
      "people/#{id}"
    end
    
  end
end
