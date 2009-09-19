module MySpace
  # Parent class of our local exceptions
  class MySpaceException < Exception
  end

  # You tried to pass an invalid value as a parameter to a REST call.
  # The REST error responses are not very elucidating, so we try to
  # catch these before sending them off.
  class BadIdentifier < MySpaceException
    attr_reader :parameter, :identifier
    def initialize(parameter, identifier)
      @parameter = parameter
      @identifier = identifier
    end
  end

  # A REST call failed for some reason.
  class RestException < MySpaceException
    attr_reader :code, :message, :url
    def initialize(code, message, url)
      @code = code
      @message = message
      @url = url
    end

    def to_s
      "#<MySpace::RestException: #{@code}: '#{@message}' loading '#{@url}'>"
    end
  end

  # A REST call failed because the caller doesn't have permission to
  # call it.
  class PermissionDenied < RestException
    def to_s
      "#<PermissionDenied loading '#{url}'>"
    end
  end

  # A REST call timed out.  Should probably just try again.
  class TimeoutException < Interrupt
    attr_accessor :url, :timeout
  end
end
