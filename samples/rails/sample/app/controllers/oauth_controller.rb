require 'myspace'

require File.expand_path(File.join(File.dirname(__FILE__), "/../../../consumer_key.rb"))

class OauthController < ApplicationController
  include ConsumerKey

  def index
    redirect_to(:action => :profile) if session[:authed_token]
  end

  def start_auth
    myspace = MySpace::MySpace.new(CONSUMER_KEY, CONSUMER_SECRET)
    request_token = myspace.get_request_token
    callback_url = url_for(:action => :callback, :only_path => false)
    auth_url = myspace.get_authorization_url(request_token, callback_url)
    session[:unauthed_token] = {:token => request_token.token, :secret => request_token.secret}
    redirect_to(auth_url)
  end

  def callback
    unless session[:unauthed_token]
      flash[:error] = "No un-authed token found in session"
      render(:action => :error)
      return
    end
    myspace = MySpace::MySpace.new(CONSUMER_KEY, CONSUMER_SECRET,
                                   :request_token => session[:unauthed_token][:token],
                                   :request_token_secret => session[:unauthed_token][:secret])
    myspace.http_logger = logger
    # unless session[:unauthed_token][:token] == params[:oauth_token]
    #   p("request_token: #{request_token.token}, returned #{params[:oauth_token]}")
    #   flash[:error] = "Something went wrong! Tokens do not match"
    #   render(:action => :error)
    #   return 
    # end
    access_token = myspace.get_access_token
    session[:authed_token] = {:token => access_token.token, :secret => access_token.secret}
    redirect_to(:action => :profile)
  end

  def profile
    unless session[:authed_token]
      flash[:error] = "You need an access token in the session!"
      render(:action => :error)
      return
    end

    access_token = session[:authed_token][:token]
    access_token_secret = session[:authed_token][:secret]

    logger.info("############################################################")
    logger.info("TOKEN = '#{access_token}' unless const_defined?('TOKEN')")
    logger.info("SECRET = '#{access_token_secret}' unless const_defined?('SECRET')")
    logger.info("############################################################")

    myspace = MySpace::MySpace.new(CONSUMER_KEY, CONSUMER_SECRET,
                                   :access_token => access_token,
                                   :access_token_secret => access_token_secret)
    myspace.http_logger = logger
    @user_id = myspace.get_userid
    @profile_data = myspace.get_profile(@user_id)
    @friends_data = myspace.get_friends(@user_id)
    session[:authed_token] = nil
  end
end
