require 'rexml/element'
require 'rexml/formatters/default'

# fixes exception when element is too big to fit on a line
module REXML
  module Formatters
    # Pretty-prints an XML document.  This destroys whitespace in text nodes
    # and will insert carriage returns and indentations.
    #
    # TODO: Add an option to print attributes on new lines
    class Pretty < Default
      def wrap(string, width)
#         p("wrap(" + string.to_s + "," + width.to_s + ")")
        # Recursively wrap string at width.
        return string if string.length <= width
        place = string.rindex(' ', width) # Position in string with last ' ' before cutoff
        return string unless place        # too wide, but no spaces to break
        return string[0,place] + "\n" + wrap(string[place+1..-1], width)
      end
    end
  end

  class Document < Element
    def pretty_print(q)
      write($stdout, 2)
    end
  end
end


module OAuth::RequestProxy::Net
  module HTTP
    class HTTPRequest < OAuth::RequestProxy::Base
      def query_string
        params = [ query_params, auth_header_params ]
        is_form_urlencoded = request['Content-Type'] != nil && request['Content-Type'].downcase == 'application/x-www-form-urlencoded'
        params << post_params if ['POST', 'PUT'].include?(method.to_s.upcase) && is_form_urlencoded
        params.compact.join('&')
      end
    end
  end
end
