require 'test/unit'
require 'myspace'

class TC_Albums < Test::Unit::TestCase
  include MySpaceTest

  def test_albums
    obj = nil
    [@ms_offsite, @ms_onsite].each do |ms|
      BAD_IDS.each do |value|
        assert_raise(MySpace::BadIdentifier) do
          obj = ms.get_albums(value)
        end
      end
      assert_nothing_raised do
        obj = ms.get_albums(USER_ID)
      end
      assert_equal(1, obj['count'])
      albums = obj['albums']
      assert_instance_of(Array, albums)
      assert_equal(1, albums.length)
      album = albums[0]
      assert_instance_of(Hash, album)
      album_id = album['id'].to_s
      assert_equal('40418', album_id)
      title = album['title']
      assert_instance_of(String, title)
      # oops this is culture specific
      # assert_equal('My Photos', title)
    end
  end

  # {"albums"=>
  #   [{"photosUri"=>
  #      "http://api.myspace.com/v1/users/456073223/albums/40418/photos",
  #      "photoCount"=>1,
  #      "location"=>"",
  #      "title"=>"My Photos",
  #      "id"=>40418,
  #      "defaultImage"=>
  #      "http://c1.ac-images.myspacecdn.com/images02/45/m_f820313641924f0f90004932c8bc310c.jpg",
  #      "privacy"=>"Everyone",
  #      "user"=>
  #      {"name"=>"Bob",
  #        "uri"=>"http://api.myspace.com/v1/users/456073223",
  #        "webUri"=>"http://www.myspace.com/bobvontestacount",
  #        "largeImage"=>
  #        "http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg",
  #        "userType"=>"RegularUser",
  #        "userId"=>456073223,
  #        "image"=>
  #        "http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg"},
  #      "albumUri"=>"http://api.myspace.com/v1/users/456073223/albums/40418"}],
  #   "count"=>1,
  #   "user"=>
  #   {"name"=>"Bob",
  #     "uri"=>"http://api.myspace.com/v1/users/456073223",
  #     "webUri"=>"http://www.myspace.com/bobvontestacount",
  #     "largeImage"=>
  #     "http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg",
  #     "userType"=>"RegularUser",
  #     "userId"=>456073223,
  #     "image"=>
  #     "http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg"}}

  def test_album
    obj = nil
    [@ms_offsite, @ms_onsite].each do |ms|
      BAD_IDS.each do |value|
        assert_raise(MySpace::BadIdentifier) do
          obj = ms.get_album(value, ALBUM_ID)
        end
      end
      BAD_IDS.each do |value|
        assert_raise(MySpace::BadIdentifier) do
          obj = ms.get_album(USER_ID, value)
        end
      end
      assert_raise(MySpace::RestException) do 
        obj = ms.get_album(USER_ID, "1234")
      end
      assert_nothing_raised do
        obj = ms.get_album(USER_ID, ALBUM_ID)
      end
      assert_equal(1, obj['count'])
      photos = obj['photos']
      assert_instance_of(Array, photos)
      assert_equal(1, photos.length)
      photo = photos[0]
      assert_instance_of(Hash, photo)
      photo_id = photo['id'].to_s
      assert_equal(PHOTO_ID, photo_id)
      caption = photo['caption']
      assert_instance_of(String, caption)
      assert_equal('', caption)
    end
  end

  # {"photos"=>
  #   [{"smallImageUri"=>
  #      "http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg",
  #      "photoUri"=>
  #      "http://api.myspace.com/v1/users/456073223/albums/40418/photos/100809",
  #      "id"=>100809,
  #      "uploadDate"=>"2/27/2009 10:14:12 AM",
  #      "caption"=>"",
  #      "lastUpdatedDate"=>"",
  #      "imageUri"=>
  #      "http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg",
  #      "user"=>
  #      {"name"=>"Bob",
  #        "uri"=>"http://api.myspace.com/v1/users/456073223",
  #        "webUri"=>"http://www.myspace.com/bobvontestacount",
  #        "largeImage"=>
  #        "http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg",
  #        "userType"=>"RegularUser",
  #        "userId"=>456073223,
  #        "image"=>
  #        "http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg"}}],
  #   "count"=>1,
  #   "user"=>
  #   {"name"=>"Bob",
  #     "uri"=>"http://api.myspace.com/v1/users/456073223",
  #     "webUri"=>"http://www.myspace.com/bobvontestacount",
  #     "largeImage"=>
  #     "http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg",
  #     "userType"=>"RegularUser",
  #     "userId"=>456073223,
  #     "image"=>
  #     "http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg"}}
end
