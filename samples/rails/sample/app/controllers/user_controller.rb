require 'pathname'

require "openid"
require 'openid/extensions/sreg'
require 'openid/extensions/pape'
require 'openid/store/filesystem'

require 'myspace'

require File.expand_path(File.join(File.dirname(__FILE__), "/../../../consumer_key.rb"))

class UserController < ApplicationController
  include ConsumerKey

  def index
    @is_logged_in = session[:userid] && session[:access_token] && session[:access_token_secret]
    if @is_logged_in
      @userid = session[:userid]
      @ms = MySpace::MySpace.new(CONSUMER_KEY, CONSUMER_SECRET,
                                 :access_token => session[:access_token],
                                 :access_token_secret => session[:access_token_secret])
      @check_user = @userid == @ms.get_userid
      @profile_ext_data = @ms.get_profile(@userid, :detail => :extended)
      @profile_data = @ms.get_profile(@userid)
      @friends_data = @ms.get_friends(@userid)
      begin
        @activities_data = @ms.get_activities(@userid)
        @friends_activities_data = @ms.get_friends_activities(@userid)
      rescue MySpace::PermissionDenied => e
        logger.info("Need to get whitelisted for activities: #{e.inspect}")
      end
    end
  end

  def complete
    current_url = url_for(:action => 'complete', :only_path => false)
    parameters = params.reject{|k,v|request.path_parameters[k]}
    @oidresp = consumer.complete(parameters, current_url)
    case @oidresp.status
    when OpenID::Consumer::FAILURE
      if @oidresp.display_identifier
        flash[:error] = ("Verification of #{@oidresp.display_identifier}"\
                         " failed: #{@oidresp.message}")
      else
        flash[:error] = "Verification failed: #{@oidresp.message}"
      end
    when OpenID::Consumer::SUCCESS
      flash[:success] = ("Verification of #{@oidresp.display_identifier}"\
                         " succeeded.")
      @oid = @oidresp.display_identifier
      @esc_identity = CGI.escape(@oid)
      @cid = @oidresp.endpoint.canonical_id

      myspace = MySpace::MySpace.new(CONSUMER_KEY, CONSUMER_SECRET)
      myspace.http_logger = logger
      oauth_resp = MySpace::OAuth::Response.from_success_response(@oidresp, myspace.consumer)
      token = oauth_resp.authorized_request_token
      if (token)
        access_token = myspace.get_access_token(token)
        logger.info("############################################################")
        logger.info("TOKEN = '#{access_token.token}' unless const_defined?('TOKEN')")
        logger.info("SECRET = '#{access_token.secret}' unless const_defined?('SECRET')")
        logger.info("############################################################")
        @user_id = myspace.get_userid()
        session[:userid] = @user_id
        session[:access_token] = access_token.token
        session[:access_token_secret] = access_token.secret
        @profile_data = myspace.get_profile(@user_id)
        @friends_data = myspace.get_friends(@user_id)
      end

    when OpenID::Consumer::SETUP_NEEDED
      flash[:alert] = "Immediate request failed - Setup Needed"
    when OpenID::Consumer::CANCEL
      flash[:alert] = "OpenID transaction cancelled."
    end
  end

  def logout
    session[:userid] = nil
    session[:access_token] = nil
    session[:access_token_secret] = nil
    redirect_to :action => :index
  end

  def consumer
    if @consumer.nil?
      dir = Pathname.new(RAILS_ROOT).join('db').join('cstore')
      store = OpenID::Store::Filesystem.new(dir)
      @consumer = OpenID::Consumer.new(session, store)
    end
    return @consumer
  end
end
