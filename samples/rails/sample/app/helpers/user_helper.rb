require 'rexml/xpath'

module UserHelper
  def display_name
    @profile_data['basicprofile']['name']
  end

  def profile_age
    @profile_data['age']
  end

  def profile_city
    @profile_data['city']
  end

  def profile_pic
    @profile_data['basicprofile']['image'].sub(/\/[sl]_/i, '/m_')
  end

  def profile_last_update
    @profile_data['basicprofile']['lastUpdatedDate']
  end

  def profile_headline
    @profile_ext_data['headline']
  end

  def profile_about_me
    @profile_data['aboutme']
  end

  def profile_to_meet
    remove_html(@profile_ext_data['desiretomeet'])
  end

  def profile_name
    remove_html(@profile_data['basicprofile']['name'])
  end

  def profile_interests
    remove_html(@profile_ext_data['interests'])
  end

  def profile_music
    remove_html(@profile_ext_data['music'])
  end

  def profile_movies
    remove_html(@profile_ext_data['movies'])
  end

  def profile_television
    remove_html(@profile_ext_data['television'])
  end

  def profile_books
    remove_html(@profile_ext_data['books'])
  end

  def profile_heroes
    remove_html(@profile_ext_data['heroes'])
  end

  def profile_more_pics
    "http://viewmorepics.myspace.com/index.cfm?fuseaction=user.viewAlbums&friendID=#{@userid}"
  end

  def profile_more_vids
    "http://vids.myspace.com/index.cfm?fuseaction=vids.channel&channelID=#{@userid}"
  end

  def profile_more_play
    "http://music.myspace.com/index.cfm?fuseaction=music.singleplaylist&friendid=#{@userid}&plid="
  end

  def remove_html(str)
    return "" unless str
    str.sub(/<.*?>|<.*?\/>|<\/.*?>/, ' ')
  end

  def each_song(doc, &block)
    REXML::XPath.each(doc, '//entry/category[@label="SongUpload" or @label="ProfileSongAdd"]/..', &block)
  end

  def compute_realm
    uri = URI::parse(url_for(:action=>:index, :only_path => false))
    uri.path = '/'
    uri.to_s
  end
end
