module MySpace
  # The MySpace API object provides access to the MySpace REST API.
  class MySpace
    APPLICATION_TYPE_ONSITE     = 'onsite'      unless const_defined?('APPLICATION_TYPE_ONSITE')
    APPLICATION_TYPE_OFFSITE    = 'offsite'     unless const_defined?('APPLICATION_TYPE_OFFSITE')

    OAUTH_SITES = {
      :prod => 'http://api.myspace.com',
      :stage => 'http://stage-api.myspace.com'
    } unless const_defined?('OAUTH_SITES')
    
    OAUTH_REQUEST_TOKEN_URL = '/request_token'  unless const_defined?('OAUTH_REQUEST_TOKEN_URL')
    OAUTH_AUTHORIZATION_URL = '/authorize'      unless const_defined?('OAUTH_AUTHORIZATION_URL')
    OAUTH_ACCESS_TOKEN_URL  = '/access_token'   unless const_defined?('OAUTH_ACCESS_TOKEN_URL')

    # tests regularly timeout at 2 seconds
    TIMEOUT_SECS = 3 unless const_defined?('TIMEOUT_SECS')


    EndPoint.define(:user_info,                '/v1/user',                                     :get,    :v1_json)
    EndPoint.define(:albums,                   '/v1/users/{user_id}/albums',                   :get,    :v1_json)
    EndPoint.define(:album_info,               '/v1/users/{user_id}/albums/{album_id}',        :get,    :v1_json)
    EndPoint.define(:album,                    '/v1/users/{user_id}/albums/{album_id}/photos', :get,    :v1_json)
    EndPoint.define(:friends,                  '/v1/users/{user_id}/friends',                  :get,    :v1_json)
    EndPoint.define(:friendship,               '/v1/users/{user_id}/friends/{friend_ids}',     :get,    :v1_json)
    EndPoint.define(:friends_list,             '/v1/users/{user_id}/friendslist/{friend_ids}', :get,    :v1_json)
    EndPoint.define(:mood_get,                 '/v1/users/{user_id}/mood',                     :get,    :v1_json)
    EndPoint.define(:mood_put,                 '/v1/users/{user_id}/mood',                     :put)
    EndPoint.define(:moods,                    '/v1/users/{user_id}/moods',                    :get,    :v1_json)
    EndPoint.define(:photos,                   '/v1/users/{user_id}/photos',                   :get,    :v1_json)
    EndPoint.define(:photo,                    '/v1/users/{user_id}/photos/{photo_id}',        :get,    :v1_json)
    EndPoint.define(:profile,                  '/v1/users/{user_id}/profile',                  :get,    :v1_json)
    EndPoint.define(:status_get,               '/v1/users/{user_id}/status',                   :get,    :v1_json)
    EndPoint.define(:status_put,               '/v1/users/{user_id}/status',                   :put)
    EndPoint.define(:videos,                   '/v1/users/{user_id}/videos',                   :get,    :v1_json)
    EndPoint.define(:video,                    '/v1/users/{user_id}/videos/{video_id}',        :get,    :v1_json)
    EndPoint.define(:activities,               '/v1/users/{user_id}/activities.atom',          :get)
    EndPoint.define(:friends_activities,       '/v1/users/{user_id}/friends/activities.atom',  :get)
    EndPoint.define(:appdata_global_get,       '/v1/appdata/global',                           :get,    :v1_json)
    EndPoint.define(:appdata_global_keys_get,  '/v1/appdata/global/{keys}',                    :get,    :v1_json)
    EndPoint.define(:appdata_global_put,       '/v1/appdata/global',                           :put)
    EndPoint.define(:appdata_global_delete,    '/v1/appdata/global/{keys}',                    :delete)
    EndPoint.define(:appdata_user_get,         '/v1/users/{user_id}/appdata',                  :get,    :v1_json)
    EndPoint.define(:appdata_user_keys_get,    '/v1/users/{user_id}/appdata/{keys}',           :get,    :v1_json)
    EndPoint.define(:appdata_user_put,         '/v1/users/{user_id}/appdata',                  :put)
    EndPoint.define(:appdata_user_delete,      '/v1/users/{user_id}/appdata/{keys}',           :delete)
    EndPoint.define(:appdata_friends_get,      '/v1/users/{user_id}/friends/appdata',          :get,    :v1_json)
    EndPoint.define(:appdata_friends_keys_get, '/v1/users/{user_id}/friends/appdata/{keys}',   :get,    :v1_json)
    EndPoint.define(:indicators,               '/v1/users/{user_id}/indicators',               :get,    :v1_json)


    attr_reader :consumer
    attr_accessor :http_logger
    attr_accessor :request_token
    attr_accessor :access_token

    # Save the application key/secret(s) and initialize OAuth code.
    #
    # If optional param +:application_type+ is passed, it must be one
    # of +MySpace::APPLICATION_TYPE_ONSITE+ or
    # +MySpace::APPLICATION_TYPE_OFFSITE+.  If the application is an
    # onsite application, an access token is not required, since the
    # user must separately give your application permission to access
    # their data.  If the application is an offsite application, it
    # must get an access token from the user to access their data.
    #
    # If optional param +:request_token+ is passed
    # +:request_token_secret+ must also be passed, and they will be
    # used to create the default argument to
    # +MySpace#get_access_token+ below.  If optional param
    # +:access_token+ is passed, +:access_token_secret+ must also be
    # passed, and they will be used to create the access token for the
    # REST API calls.
    #
    # If optional param +:site+ is passed, it must be either +:prod+
    # or +:stage+, and MySpace OAuth calls will be directed to either
    # the production or stage API server accordingly.
    def initialize(oauth_token_key, oauth_token_secret, params = {})
      @http_logger = params[:logger]
      site = params[:site] || :prod
      @consumer = ::OAuth::Consumer.new(oauth_token_key,
                                        oauth_token_secret,
                                        :scheme => :query_string,
                                        # :scheme => :header,
                                        :http_method => :get,
                                        :site => OAUTH_SITES[site],
                                        :request_token_path => OAUTH_REQUEST_TOKEN_URL,
                                        :access_token_path => OAUTH_ACCESS_TOKEN_URL,
                                        :authorize_path => OAUTH_AUTHORIZATION_URL)

      if params[:application_type] == APPLICATION_TYPE_ONSITE
        @access_token = ::OAuth::AccessToken.new(@consumer, "", "")
      elsif params[:access_token]
        @access_token = ::OAuth::AccessToken.new(@consumer,
                                                 params[:access_token],
                                                 params[:access_token_secret])
      end
      if params[:request_token]
        @request_token = ::OAuth::RequestToken.new(@consumer,
                                                   params[:request_token],
                                                   params[:request_token_secret])
      end
    end

    # Get an unauthorized request token from MySpace.
    def get_request_token
      @consumer.get_request_token
    end

    # Get the url to which to redirect the user in order to authorize
    # our access to their account.  This url will redirect back to
    # +callback_url+ once the user authorizes us.
    def get_authorization_url(request_token, callback_url)
      "#{request_token.authorize_url}&oauth_callback=#{CGI::escape(callback_url)}"
    end

    # Get an access token once the user has authorized us.
    def get_access_token(request_token = @request_token)
      # response = @consumer.token_request(@consumer.http_method,
      #                                    (@consumer.access_token_url? ? @consumer.access_token_url : @consumer.access_token_path),
      #                                    request_token,
      #                                    {},
      #                                    headers)

      # @access_token = ::OAuth::AccessToken.new(@consumer, response[:oauth_token], response[:oauth_token_secret])
      @access_token = request_token.get_access_token
    end

    # Get the user id of the currently logged in user.
    def get_userid()
      user_info = call_myspace_api(:user_info, :v1_json => true)
      user_info['userId'].to_s
    end

    # Get the photo album descriptions for the user +user_id+:
    #
    # 	{"albums"=>
    # 	  [{"photosUri"=>
    # 	     "http://api.myspace.com/v1/users/456073223/albums/40418/photos",
    # 	     "photoCount"=>1,
    # 	     "location"=>"",
    # 	     "title"=>"My Photos",
    # 	     "id"=>40418,
    # 	     "defaultImage"=>
    # 	     "http://c1.ac-images.myspacecdn.com/images02/45/m_f820313641924f0f90004932c8bc310c.jpg",
    # 	     "privacy"=>"Everyone",
    # 	     "user"=>
    # 	     {"name"=>"Bob",
    # 	       "uri"=>"http://api.myspace.com/v1/users/456073223",
    # 	       "webUri"=>"http://www.myspace.com/bobvontestacount",
    # 	       "largeImage"=>
    # 	       "http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg",
    # 	       "userType"=>"RegularUser",
    # 	       "userId"=>456073223,
    # 	       "image"=>
    # 	       "http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg"},
    # 	     "albumUri"=>"http://api.myspace.com/v1/users/456073223/albums/40418"}],
    # 	  "count"=>1,
    # 	  "user"=>
    # 	  {"name"=>"Bob",
    # 	    "uri"=>"http://api.myspace.com/v1/users/456073223",
    # 	    "webUri"=>"http://www.myspace.com/bobvontestacount",
    # 	    "largeImage"=>
    # 	    "http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg",
    # 	    "userType"=>"RegularUser",
    # 	    "userId"=>456073223,
    # 	    "image"=>
    # 	    "http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg"}}
    def get_albums(user_id, params = {})
      user_id = user_id.to_s
      validate_identifier(:user_id, user_id)
      call_myspace_api(:albums, params.dup.update(:user_id => user_id, :v1_json => true))
    end

    # Get the photo album description for user +user_id+ and album +album_id+
    #
    # {"photosUri"=>"http://api.myspace.com/v1/users/456073223/albums/40418/photos",
    #  "photoCount"=>1,
    #  "location"=>"",
    #  "title"=>"My Photos",
    #  "id"=>40418,
    #  "defaultImage"=>
    #    "http://c1.ac-images.myspacecdn.com/images02/45/m_f820313641924f0f90004932c8bc310c.jpg",
    #  "privacy"=>"Everyone",
    #  "user"=>
    #    {"name"=>"Bob",
    #    "uri"=>"http://api.myspace.com/v1/users/456073223",
    #    "webUri"=>"http://www.myspace.com/bobvontestacount",
    #    "largeImage"=>
    #    "http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg",
    #    "userType"=>"RegularUser",
    #    "userId"=>456073223,
    #    "image"=>
    #    "http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg"},
    #  "albumUri"=>"http://api.myspace.com/v1/users/456073223/albums/40418"}
    def get_album_info(user_id, album_id, params = {})
      user_id = user_id.to_s
      validate_identifier(:user_id, user_id)
      album_id = album_id.to_s
      validate_identifier(:album_id, album_id)
      call_myspace_api(:album_info, params.dup.update(:user_id => user_id, :album_id => album_id, :v1_json => true))
    end

    # Get the photo descriptions for the photos of album +album_id+
    # for the user +user_id+:
    #
    # 	{"photos"=>
    # 	  [{"smallImageUri"=>
    # 	     "http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg",
    # 	     "photoUri"=>
    # 	     "http://api.myspace.com/v1/users/456073223/albums/40418/photos/100809",
    # 	     "id"=>100809,
    # 	     "uploadDate"=>"2/27/2009 10:14:12 AM",
    # 	     "caption"=>"",
    # 	     "lastUpdatedDate"=>"",
    # 	     "imageUri"=>
    # 	     "http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg",
    # 	     "user"=>
    # 	     {"name"=>"Bob",
    # 	       "uri"=>"http://api.myspace.com/v1/users/456073223",
    # 	       "webUri"=>"http://www.myspace.com/bobvontestacount",
    # 	       "largeImage"=>
    # 	       "http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg",
    # 	       "userType"=>"RegularUser",
    # 	       "userId"=>456073223,
    # 	       "image"=>
    # 	       "http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg"}}],
    # 	  "count"=>1,
    # 	  "user"=>
    # 	  {"name"=>"Bob",
    # 	    "uri"=>"http://api.myspace.com/v1/users/456073223",
    # 	    "webUri"=>"http://www.myspace.com/bobvontestacount",
    # 	    "largeImage"=>
    # 	    "http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg",
    # 	    "userType"=>"RegularUser",
    # 	    "userId"=>456073223,
    # 	    "image"=>
    # 	    "http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg"}}
    def get_album(user_id, album_id, params = {})
      user_id = user_id.to_s
      validate_identifier(:user_id, user_id)
      album_id = album_id.to_s
      validate_identifier(:album_id, album_id)
      call_myspace_api(:album, params.dup.update(:user_id => user_id, :album_id => album_id, :v1_json => true))
    end

    # Gets the list of friends for the user +user_id+:
    #
    # 	{"topFriends"=>"http://api.myspace.com/v1/users/456073223/friends?list=top",
    # 	  "Friends"=>
    # 	  [{"name"=>"Tom",
    # 	     "uri"=>"http://api.myspace.com/v1/users/6221",
    # 	     "webUri"=>"http://www.myspace.com/tom",
    # 	     "largeImage"=>"http://b2.ac-images.myspacecdn.com/00000/20/52/2502_l.jpg",
    # 	     "userType"=>"RegularUser",
    # 	     "userId"=>6221,
    # 	     "image"=>"http://b2.ac-images.myspacecdn.com/00000/20/52/2502_s.jpg"}],
    # 	  "count"=>1,
    # 	  "user"=>
    # 	  {"name"=>"Bob",
    # 	    "uri"=>"http://api.myspace.com/v1/users/456073223",
    # 	    "webUri"=>"http://www.myspace.com/bobvontestacount",
    # 	    "largeImage"=>
    # 	    "http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg",
    # 	    "userType"=>"RegularUser",
    # 	    "userId"=>456073223,
    # 	    "image"=>
    # 	    "http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg"}}
    def get_friends(user_id, params = {})
      user_id = user_id.to_s
      validate_identifier(:user_id, user_id)
      call_myspace_api(:friends, params.dup.update(:user_id => user_id, :v1_json => true))
    end

    # Tests whether user +user_id+ is friends with one or more other users:
    #
    # 	{"friendship"=>
    # 	  [{"areFriends"=>true, "friendId"=>6221},
    # 	   {"areFriends"=>false, "friendId"=>12341234},
    # 	   {"areFriends"=>true, "friendId"=>456073223}],
    # 	  "user"=>
    # 	  {"name"=>"Bob",
    # 	    "uri"=>"http://api.myspace.com/v1/users/456073223",
    # 	    "webUri"=>"http://www.myspace.com/bobvontestacount",
    # 	    "largeImage"=>
    # 	    "http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg",
    # 	    "userType"=>"RegularUser",
    # 	    "userId"=>456073223,
    # 	    "image"=>
    # 	    "http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg"}}
    def get_friendship(user_id, *friend_ids)
      user_id = user_id.to_s
      validate_identifier(:user_id, user_id)
      friend_ids.each do |friend_id|
        friend_id = friend_id.to_s
        validate_identifier(:friend_ids, friend_id)
      end
      call_myspace_api(:friendship, :user_id => user_id, :friend_ids => friend_ids.join(';'), :v1_json => true)
    end

    # Gets the list of friends for the user +user_id+, for the friends
    # in +friend_ids+.  Use this call if you only need information
    # about a specific set of friends whose ids you already know.
    def get_friends_list(user_id, *friend_ids)
      user_id = user_id.to_s
      validate_identifier(:user_id, user_id)
      friend_ids.each do |friend_id|
        friend_id = friend_id.to_s
        validate_identifier(:friend_ids, friend_id)
      end
      call_myspace_api(:friends_list, :user_id => user_id, :friend_ids => friend_ids.join(';'), :v1_json => true)
    end

    # Gets the mood of user +user_id+:
    #
    # 	{"mood"=>"tested",
    # 	  "moodImageUrl"=>
    # 	  "http://x.myspacecdn.com/images/blog/moods/iBrads/indescribable.gif",
    # 	  "moodLastUpdated"=>"2/27/2009 10:19:25 AM",
    # 	  "user"=>
    # 	  {"name"=>"Bob",
    # 	    "uri"=>"http://api.myspace.com/v1/users/456073223",
    # 	    "webUri"=>"http://www.myspace.com/bobvontestacount",
    # 	    "largeImage"=>
    # 	    "http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg",
    # 	    "userType"=>"RegularUser",
    # 	    "userId"=>456073223,
    # 	    "image"=>
    # 	    "http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg"}}
    def get_mood(user_id, params = {})
      user_id = user_id.to_s
      validate_identifier(:user_id, user_id)
      call_myspace_api(:mood_get, params.dup.update(:user_id => user_id, :v1_json => true))
    end

    # Sets the mood of the user +user_id+ to +mood_id+, which must be
    # a number from this list:
    #
    # http://wiki.developer.myspace.com/index.php?title=Myspace_mood_data_names_codes_images
    def set_mood(user_id, mood_id)
      user_id = user_id.to_s
      validate_identifier(:user_id, user_id)
      mood_id = mood_id.to_s
      validate_identifier(:mood_id, mood_id)
      call_myspace_api(:mood_put, :user_id => user_id, :body => {:mood => mood_id})
    end

    # Gets and caches the list of available moods for user +user_id+.
    def moods(user_id)
      @moods ||= {}
      @moods[user_id] ||= get_moods(user_id)
    end

    # Gets the mood names available for user +user_id+.
    def mood_names(user_id)
      moods(user_id).collect do |mood|
        mood['moodName']
      end
    end

    # Given a +user_id+ and the name of a mood, returns the
    # corresponding mood id
    def mood_id(user_id, name)
      moods(user_id).each do |mood|
        return mood['moodId'] if mood['moodName'] == name
      end
    end

    # Gets the list of available moods for user +user_id+.
    def get_moods(user_id, params = {})
      user_id = user_id.to_s
      validate_identifier(:user_id, user_id)
      moods = call_myspace_api(:moods, params.dup.update(:user_id => user_id, :v1_json => true))
      moods['moods']
    end

    # Gets the photo descriptions for the photos that belong to user +user_id+:
    #
    # 	{"photos"=>
    # 	  [{"smallImageUri"=>
    # 	     "http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg",
    # 	     "photoUri"=>"http://api.myspace.com/v1/users/456073223/photos/100809",
    # 	     "id"=>100809,
    # 	     "uploadDate"=>"2/27/2009 10:14:12 AM",
    # 	     "caption"=>"",
    # 	     "lastUpdatedDate"=>"",
    # 	     "imageUri"=>
    # 	     "http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg",
    # 	     "user"=>
    # 	     {"name"=>"Bob",
    # 	       "uri"=>"http://api.myspace.com/v1/users/456073223",
    # 	       "webUri"=>"http://www.myspace.com/bobvontestacount",
    # 	       "largeImage"=>
    # 	       "http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg",
    # 	       "userType"=>"RegularUser",
    # 	       "userId"=>456073223,
    # 	       "image"=>
    # 	       "http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg"}}],
    # 	  "count"=>1,
    # 	  "user"=>
    # 	  {"name"=>"Bob",
    # 	    "uri"=>"http://api.myspace.com/v1/users/456073223",
    # 	    "webUri"=>"http://www.myspace.com/bobvontestacount",
    # 	    "largeImage"=>
    # 	    "http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg",
    # 	    "userType"=>"RegularUser",
    # 	    "userId"=>456073223,
    # 	    "image"=>
    # 	    "http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg"}}
    def get_photos(user_id, params = {})
      user_id = user_id.to_s
      validate_identifier(:user_id, user_id)
      call_myspace_api(:photos, params.dup.update(:user_id => user_id, :v1_json => true))
    end

    # Gets the photo description for photo +photo_id+ for user +user_id+:
    #
    # 	{"smallImageUri"=>
    # 	  "http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg",
    # 	  "photoUri"=>"http://api.myspace.com/v1/users/456073223/photos/100809",
    # 	  "id"=>100809,
    # 	  "uploadDate"=>"2/27/2009 10:14:12 AM",
    # 	  "caption"=>"",
    # 	  "lastUpdatedDate"=>"",
    # 	  "imageUri"=>
    # 	  "http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg",
    # 	  "user"=>
    # 	  {"name"=>"Bob",
    # 	    "uri"=>"http://api.myspace.com/v1/users/456073223",
    # 	    "webUri"=>"http://www.myspace.com/bobvontestacount",
    # 	    "largeImage"=>
    # 	    "http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg",
    # 	    "userType"=>"RegularUser",
    # 	    "userId"=>456073223,
    # 	    "image"=>
    # 	    "http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg"}}
    def get_photo(user_id, photo_id, params = {})
      user_id = user_id.to_s
      validate_identifier(:user_id, user_id)
      photo_id = photo_id.to_s
      validate_identifier(:photo_id, photo_id)
      call_myspace_api(:photo, params.dup.update(:user_id => user_id, :photo_id => photo_id, :v1_json => true))
    end

    # Gets the profile info for user +user_id+:
    #
    # 	{"region"=>"California",
    # 	  "city"=>"BEVERLY HILLS",
    # 	  "country"=>"US",
    # 	  "postalcode"=>"90210",
    # 	  "gender"=>"Male",
    # 	  "type"=>"full",
    # 	  "culture"=>"en-US",
    # 	  "aboutme"=>"",
    # 	  "hometown"=>"",
    # 	  "basicprofile"=>
    # 	  {"name"=>"Bob",
    # 	    "uri"=>"http://api.myspace.com/v1/users/456073223",
    # 	    "webUri"=>"http://www.myspace.com/bobvontestacount",
    # 	    "largeImage"=>
    # 	    "http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg",
    # 	    "userId"=>456073223,
    # 	    "lastUpdatedDate"=>"2/27/2009 10:20:02 AM",
    # 	    "image"=>
    # 	    "http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg"},
    # 	  "age"=>88,
    # 	  "maritalstatus"=>"Single"}
    def get_profile(user_id, params = {})
      user_id = user_id.to_s
      validate_identifier(:user_id, user_id)
      call_myspace_api(:profile, params.dup.update(:user_id => user_id, :v1_json => true))
    end

    # Gets the status of user +user_id+:
    #
    # 	{"mood"=>"tested",
    # 	  "moodImageUrl"=>
    # 	  "http://x.myspacecdn.com/images/blog/moods/iBrads/indescribable.gif",
    # 	  "moodLastUpdated"=>"2/27/2009 10:19:25 AM",
    # 	  "user"=>
    # 	  {"name"=>"Bob",
    # 	    "uri"=>"http://api.myspace.com/v1/users/456073223",
    # 	    "webUri"=>"http://www.myspace.com/bobvontestacount",
    # 	    "largeImage"=>
    # 	    "http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg",
    # 	    "userType"=>"RegularUser",
    # 	    "userId"=>456073223,
    # 	    "image"=>
    # 	    "http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg"},
    # 	  "status"=>"Testing"}
    def get_status(user_id, params = {})
      user_id = user_id.to_s
      validate_identifier(:user_id, user_id)
      call_myspace_api(:status_get, params.dup.update(:user_id => user_id, :v1_json => true))
    end

    # Sets the status of the user +user_id+
    def set_status(user_id, status)
      user_id = user_id.to_s
      validate_identifier(:user_id, user_id)
      call_myspace_api(:status_put, :user_id => user_id, :body => {:status => status})
    end

    # Gets the video descriptions for the videos of user +user_id+:
    #
    # 	{"videos"=>
    # 	  [{"totalrating"=>"0",
    # 	     "title"=>"110403na",
    # 	     "resourceuserid"=>"456073223",
    # 	     "mediastatus"=>"ProcessingSuccessful",
    # 	     "dateupdated"=>"3/5/2009 11:24:23 AM",
    # 	     "country"=>"US",
    # 	     "totalviews"=>"0",
    # 	     "thumbnail"=>
    # 	     "http://d4.ac-videos.myspacecdn.com/videos02/8/thumb1_1bd4f5fde59540c2981c35b27c15a0f3.jpg",
    # 	     "language"=>"en",
    # 	     "id"=>53551799,
    # 	     "totalcomments"=>"0",
    # 	     "runtime"=>"219",
    # 	     "datecreated"=>"3/5/2009 11:24:23 AM",
    # 	     "privacy"=>"Public",
    # 	     "mediatype"=>"4",
    # 	     "description"=>"110403na",
    # 	     "user"=>
    # 	     {"name"=>"Bob",
    # 	       "uri"=>"http://api.myspace.com/v1/users/456073223",
    # 	       "webUri"=>"http://www.myspace.com/bobvontestacount",
    # 	       "largeImage"=>
    # 	       "http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg",
    # 	       "userType"=>"RegularUser",
    # 	       "userId"=>456073223,
    # 	       "image"=>
    # 	       "http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg"},
    # 	     "totalvotes"=>"0",
    # 	     "videoUri"=>"http://api.myspace.com/v1/users/456073223/videos/53551799"}],
    # 	  "count"=>1,
    # 	  "user"=>
    # 	  {"name"=>"Bob",
    # 	    "uri"=>"http://api.myspace.com/v1/users/456073223",
    # 	    "webUri"=>"http://www.myspace.com/bobvontestacount",
    # 	    "largeImage"=>
    # 	    "http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg",
    # 	    "userType"=>"RegularUser",
    # 	    "userId"=>456073223,
    # 	    "image"=>
    # 	    "http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg"}}
    def get_videos(user_id, params = {})
      user_id = user_id.to_s
      validate_identifier(:user_id, user_id)
      call_myspace_api(:videos, params.dup.update(:user_id => user_id, :v1_json => true))
    end

    # Gets the video description for the video +video_id+ of user +user_id+:
    #
    # 	{"totalrating"=>"0",
    # 	  "title"=>"110403na",
    # 	  "resourceuserid"=>"456073223",
    # 	  "mediastatus"=>"ProcessingSuccessful",
    # 	  "dateupdated"=>"3/5/2009 11:24:23 AM",
    # 	  "country"=>"US",
    # 	  "totalviews"=>"0",
    # 	  "thumbnail"=>
    # 	  "http://d1.ac-videos.myspacecdn.com/videos02/8/thumb1_461592d881c14023bcb6a73275ebc614.jpg",
    # 	  "language"=>"en",
    # 	  "id"=>53551799,
    # 	  "totalcomments"=>"0",
    # 	  "runtime"=>"219",
    # 	  "datecreated"=>"3/5/2009 11:24:23 AM",
    # 	  "privacy"=>"Public",
    # 	  "mediatype"=>"4",
    # 	  "description"=>"110403na",
    # 	  "user"=>
    # 	  {"name"=>"Bob",
    # 	    "uri"=>"http://api.myspace.com/v1/users/456073223",
    # 	    "webUri"=>"http://www.myspace.com/bobvontestacount",
    # 	    "largeImage"=>
    # 	    "http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg",
    # 	    "userType"=>"RegularUser",
    # 	    "userId"=>456073223,
    # 	    "image"=>
    # 	    "http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg"},
    # 	  "totalvotes"=>"0",
    # 	  "videoUri"=>"http://api.myspace.com/v1/users/456073223/videos/53551799"}
    def get_video(user_id, video_id, params = {})
      user_id = user_id.to_s
      validate_identifier(:user_id, user_id)
      video_id = video_id.to_s
      validate_identifier(:video_id, video_id)
      call_myspace_api(:video, params.dup.update(:user_id => user_id, :video_id => video_id, :v1_json => true))
    end

    # Gets the activity stream of user +user_id+
    def get_activities(user_id, params = {})
      user_id = user_id.to_s
      validate_identifier(:user_id, user_id)
      call_myspace_api(:activities, params.dup.update(:user_id => user_id))
    end

    # Gets the activity streams of the friends of user +user_id+
    def get_friends_activities(user_id, params = {})
      user_id = user_id.to_s
      validate_identifier(:user_id, user_id)
      call_myspace_api(:friends_activities, params.dup.update(:user_id => user_id))
    end
    
    # Gets the global application data.  This can be anything the
    # application wants.  If you pass +keys+, only return data
    # corresponding to the passed keys.
    def get_global_appdata(*keys)
      MySpace.appdata_to_hash do
        if keys.length > 0
          call_myspace_api(:appdata_global_keys_get, :keys => keys.join(';'), :v1_json => true)
        else
          call_myspace_api(:appdata_global_get, :v1_json => true)
        end
      end
    end

    def set_global_appdata(params = {})
      deletes = MySpace.remove_null_values(params)

      call_myspace_api(:appdata_global_put, :body => params) if params.length > 0
      call_myspace_api(:appdata_global_delete, :keys => deletes.join(';')) if deletes.length > 0
    end

    def clear_global_appdata(*keys)
      call_myspace_api(:appdata_global_delete, :keys => keys.join(';'))
    end

    def get_user_appdata(user_id, *keys)
      user_id = user_id.to_s
      validate_identifier(:user_id, user_id)
      MySpace.appdata_to_hash do
        if keys.length > 0
          call_myspace_api(:appdata_user_keys_get, :user_id => user_id, :keys => keys.join(';'), :v1_json => true)
        else
          call_myspace_api(:appdata_user_get, :user_id => user_id, :v1_json => true)
        end
      end
    end

    def set_user_appdata(user_id, params = {})
      user_id = user_id.to_s
      validate_identifier(:user_id, user_id)
      deletes = MySpace.remove_null_values(params)
      call_myspace_api(:appdata_user_put, :user_id => user_id, :body => params) if params.length > 0
      call_myspace_api(:appdata_user_delete, :user_id => user_id, :keys => deletes.join(';')) if deletes.length > 0
    end

    def clear_user_appdata(user_id, *keys)
      user_id = user_id.to_s
      validate_identifier(:user_id, user_id)
      call_myspace_api(:appdata_user_delete, :user_id => user_id, :keys => keys.join(';'))
    end

    def get_user_friends_appdata(user_id, *keys)
      user_id = user_id.to_s
      validate_identifier(:user_id, user_id)
      if keys.length > 0
        call_myspace_api(:appdata_friends_keys_get, :user_id => user_id, :keys => keys.join(';'), :v1_json => true)
      else
        call_myspace_api(:appdata_friends_get, :user_id => user_id, :v1_json => true)
      end.inject({}) do |hash, friend|
        hash.update(friend['userid'].to_s => MySpace.appdata_to_hash(friend))
      end
    end

    protected

    def self.remove_null_values(hash)
      hash.keys.inject([]) do |nulls, key|
        unless hash[key]
          hash.delete(key)
          nulls << key
        end
        nulls
      end
    end

    def self.appdata_to_hash(appdata = {}, &block)
      appdata = yield if block_given?
      return {} unless appdata['keyvaluecollection']
      appdata['keyvaluecollection'].inject({}) do |hash, entry|
        hash.update(entry['key'].to_sym => entry['value'])
      end
    end

    public

    def get_indicators(user_id)
      user_id = user_id.to_s
      validate_identifier(:user_id, user_id)
      call_myspace_api(:indicators, :user_id => user_id, :v1_json => true)
    end
    
    def call_myspace_api(name, params = {}, &block)
      params = params.dup
      ep = EndPoint.find(name)
      url = ep.compute_path(params)
      timeout = params.delete(:timeout) || TIMEOUT_SECS
      body = params.delete(:body)
      headers = params.delete(:headers)
      params.delete(:v1_json)
      query_str = params.collect do |key, value|
        CGI.escape(key.to_s) + '=' + CGI.escape(value.to_s)
      end.join('&')

      url << '?' + query_str if query_str.length > 0

      resp = nil
      @http_logger.info("sending: '#{url}'") if @http_logger
      begin
        Timeout::timeout(timeout, TimeoutException) do
          resp = @access_token.request(ep.method, url, body, headers)
        end
      rescue TimeoutException => e
        e.timeout = timeout
        e.url = url
        raise e
      end
      @http_logger.info("received: '#{resp.code}': '#{resp.body}'") if @http_logger

      validate_response(resp, url)

      content_type = resp['content-type']
      if content_type
        if content_type =~ /json/
          return JSON::parse(resp.body)
        elsif content_type =~ /xml/
          return REXML::Document.new(resp.body)
        end
        
        raise "unknown content type: #{content_type}"
      end
    end

    protected

    ID_REGEXP = /[0-9]+/ unless const_defined?('ID_REGEXP')

    def validate_identifier(parameter, identifier)
      raise BadIdentifier.new(parameter, identifier) unless identifier && identifier =~ ID_REGEXP
    end

    def validate_response(response, url)
      code = response.code
      case code
      when '200'
        return
      when '201'
        return
      when '401'
        raise PermissionDenied.new(code, response.message, url)
      else
        raise RestException.new(code, response.message, url) unless ['200', '201'].include?(code)
      end
    end
  end
end

