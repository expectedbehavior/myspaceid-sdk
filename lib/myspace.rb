require 'rubygems'
require 'oauth'
require 'openid/consumer'
require 'json'
require 'logger'

require 'patches'

module MySpace
  VERSION = '0.1.11'
end

require 'myspace/end_point'
require 'myspace/myspace'
require 'myspace/exceptions'
require 'myspace/oauth_request'

