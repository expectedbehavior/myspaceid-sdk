require 'pathname'

require "openid"
require 'openid/extensions/sreg'
require 'openid/extensions/pape'
require 'openid/store/filesystem'

require 'myspace'

require File.expand_path(File.join(File.dirname(__FILE__), "/../../../consumer_key.rb"))

class OpenidController < ApplicationController
  include ConsumerKey

  layout nil

  def index
    # render an openid form
  end

  def start
    begin
      identifier = params[:openid_identifier]
      if identifier.nil?
        flash[:error] = "Enter an OpenID identifier"
        redirect_to :action => 'index'
        return
      end
      oidreq = consumer.begin(identifier)
    rescue OpenID::OpenIDError => e
      flash[:error] = "Discovery failed for #{identifier}: #{e}"
      redirect_to :action => 'index'
      return
    end

    return_to = url_for :action => 'complete', :only_path => false
    #strip path off for realm
    full_uri = URI::parse(url_for(:action => 'index', :only_path => false))
    full_uri.path = '/'
    realm = full_uri.to_s
    
    req = MySpace::OAuth::Request.new(CONSUMER_KEY, nil)
    oidreq.add_extension(req)

    if oidreq.send_redirect?(realm, return_to, params[:immediate])
      redirect_to oidreq.redirect_url(realm, return_to, params[:immediate])
    else
      render :text => oidreq.html_markup(realm, return_to, params[:immediate], {'id' => 'openid_form'})
    end
  end

  def complete
    # FIXME - url_for some action is not necessarily the current URL.
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
        @profile_data = myspace.get_profile(@user_id)
        @friends_data = myspace.get_friends(@user_id)
        @album_data = myspace.get_albums(@user_id)
      end

    when OpenID::Consumer::SETUP_NEEDED
      flash[:alert] = "Immediate request failed - Setup Needed"
    when OpenID::Consumer::CANCEL
      flash[:alert] = "OpenID transaction cancelled."
    else
    end
    render :action => 'index'
  end

  private

  def consumer
    if @consumer.nil?
      dir = Pathname.new(RAILS_ROOT).join('db').join('cstore')
      store = OpenID::Store::Filesystem.new(dir)
      @consumer = OpenID::Consumer.new(session, store)
    end
    return @consumer
  end
end
