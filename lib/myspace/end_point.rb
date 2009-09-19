module MySpace
  class EndPoint
    attr_reader :method

    @@registry = {}
    # Registers a new EndPoint named +name+.
    #
    # +path+ is the path on server which may include variables in braces, e.g.
    #
    #   '/v1/users/{user_id}/profile'
    #
    # In this case, when you call +compute_path+ for this +EndPoint+,
    # you must include +user_id+ in +params+, which will be
    # substituted into the url.
    def self.define(name, path, method, *options)
      @@registry[name] = EndPoint.new(path, method, options)
    end

    # Returns the EndPoint named +name+.
    def self.find(name)
      return @@registry[name]
    end

    def initialize(path, method = :get, options = [])
      @components = EndPoint.parse_path(path)
      @method = method
      @options = options.dup
      @options.delete(:v1_json)
      @v1_json = options.include?(:v1_json)
    end

    def self.parse_path(path)
      # parse the path string looking for {var} to substitute
      fragments = []
      pos = 0
      while pos < path.length
        lbrace = path.index('{', pos)
        unless lbrace
          fragments.push(path[pos, path.length - pos])
          break
        end
        rbrace = path.index('}', lbrace)
        raise "unmatched left brace in '#{path}'" unless rbrace
        fragments.push(path[pos, lbrace - pos])
        var = path[lbrace + 1, rbrace - lbrace - 1].to_sym
        fragments.push(var)
        pos = rbrace + 1
      end

      fragments
    end

    # Computes the path to the EndPoint by substituting parameters
    # from +params+ into the path.
    #
    # WARNING: This function DESTRUCTIVELY modifies the +params+ hash
    # that you pass to it.  This is normally what you want, since you
    # don't want to substitute a parameter into the path and also pass
    # it in the query string, but make sure to make a copy first if
    # you're just passing in parameters from another caller.
    def compute_path(params)
      path = @components.inject("") do |result, cur|
        if cur.class == String
          result + cur
        elsif cur.class == Symbol
          val = params.delete(cur)
          raise "Required parameter '#{cur}' omitted" unless val
          result + val
        else
          raise "Bad path component: #{cur}"
        end
      end
      path << '.json' if @v1_json && params[:v1_json]
      path
    end
  end
end
