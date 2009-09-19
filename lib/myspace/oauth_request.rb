require 'openid/extension'
require 'openid/util'
require 'openid/message'
require 'oauth/token'

module MySpace
  module OAuth
    NS_URI = 'http://specs.openid.net/extensions/oauth/1.0'

#     begin
#       Message.register_namespace_alias(NS_URI, 'oauth')
#     rescue NamespaceAliasRegistrationError => e
#       Util.log(e)
#     end

    # An object to hold the state of a simple registration request.
    class Request < OpenID::Extension
      attr_reader :consumer, :scope, :ns_uri
      def initialize(consumer, scope)
        super()

        @ns_uri = NS_URI
        @ns_alias = 'oauth'
        @consumer = consumer
        @scope = scope
      end

      def get_extension_args
        args = {}

        args['consumer'] = @consumer
#         args['scope'] = @scope

        return args
      end
    end

    # Represents the data returned in a simple registration response
    # inside of an OpenID id_res response. This object will be
    # created by the OpenID server, added to the id_res response
    # object, and then extracted from the id_res message by the Consumer.
    class Response < OpenID::Extension
      attr_reader :ns_uri, :authorized_request_token

      def initialize(request_token = nil)
        @ns_uri = NS_URI
        @ns_alias = 'oauth'
        @authorized_request_token = request_token
      end

      # Create an Response object from an
      # OpenID::Consumer::SuccessResponse from consumer.complete
      # If you set the signed_only parameter to false, unsigned data from
      # the id_res message from the server will be processed.
      def self.from_success_response(success_response, oauth_consumer)
        args = success_response.extension_response(NS_URI, nil)
        new(::OAuth::RequestToken.new(oauth_consumer, args['request_token'], ''))
      end
    end
  end
end

