require 'test/unit'
require 'myspace'

class TC_Videos < Test::Unit::TestCase
  include MySpaceTest

  def test_videos
    [@ms_offsite, @ms_onsite].each do |ms|
      obj = nil
      BAD_IDS.each do |value|
        assert_raise(MySpace::BadIdentifier) do
          obj = ms.get_videos(value)
        end
      end
      assert_nothing_raised do
        obj = ms.get_videos(USER_ID)
      end
      assert_instance_of(Hash, obj)
      assert_equal(1, obj['count'])
      videos = obj['videos']
      assert_instance_of(Array, videos)
      assert_equal(1, videos.length)
      video = videos[0]
      video_id = video['id'].to_s
      assert_equal(VIDEO_ID, video_id)
      video_title = video['title']
      assert_instance_of(String, video_title)
      assert_equal(VIDEO_TITLE, video_title)
    end
  end

  # {"videos"=>
  #   [{"totalrating"=>"0",
  #      "title"=>"110403na",
  #      "resourceuserid"=>"456073223",
  #      "mediastatus"=>"ProcessingSuccessful",
  #      "dateupdated"=>"3/5/2009 11:24:23 AM",
  #      "country"=>"US",
  #      "totalviews"=>"0",
  #      "thumbnail"=>
  #      "http://d4.ac-videos.myspacecdn.com/videos02/8/thumb1_1bd4f5fde59540c2981c35b27c15a0f3.jpg",
  #      "language"=>"en",
  #      "id"=>53551799,
  #      "totalcomments"=>"0",
  #      "runtime"=>"219",
  #      "datecreated"=>"3/5/2009 11:24:23 AM",
  #      "privacy"=>"Public",
  #      "mediatype"=>"4",
  #      "description"=>"110403na",
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
  #      "totalvotes"=>"0",
  #      "videoUri"=>"http://api.myspace.com/v1/users/456073223/videos/53551799"}],
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

  def test_video
    [@ms_offsite, @ms_onsite].each do |ms|
      obj = nil
      BAD_IDS.each do |value|
        assert_raise(MySpace::BadIdentifier) do
          obj = ms.get_video(value, VIDEO_ID)
        end
      end
      BAD_IDS.each do |value|
        assert_raise(MySpace::BadIdentifier) do
          obj = ms.get_video(USER_ID, value)
        end
      end
      assert_nothing_raised do
        obj = ms.get_video(USER_ID, VIDEO_ID)
      end
      assert_instance_of(Hash, obj)
      video_id = obj['id'].to_s
      assert_equal(VIDEO_ID, video_id)
      video_title = obj['title']
      assert_instance_of(String, video_title)
      assert_equal(VIDEO_TITLE, video_title)
    end
  end

  # {"totalrating"=>"0",
  #   "title"=>"110403na",
  #   "resourceuserid"=>"456073223",
  #   "mediastatus"=>"ProcessingSuccessful",
  #   "dateupdated"=>"3/5/2009 11:24:23 AM",
  #   "country"=>"US",
  #   "totalviews"=>"0",
  #   "thumbnail"=>
  #   "http://d1.ac-videos.myspacecdn.com/videos02/8/thumb1_461592d881c14023bcb6a73275ebc614.jpg",
  #   "language"=>"en",
  #   "id"=>53551799,
  #   "totalcomments"=>"0",
  #   "runtime"=>"219",
  #   "datecreated"=>"3/5/2009 11:24:23 AM",
  #   "privacy"=>"Public",
  #   "mediatype"=>"4",
  #   "description"=>"110403na",
  #   "user"=>
  #   {"name"=>"Bob",
  #     "uri"=>"http://api.myspace.com/v1/users/456073223",
  #     "webUri"=>"http://www.myspace.com/bobvontestacount",
  #     "largeImage"=>
  #     "http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg",
  #     "userType"=>"RegularUser",
  #     "userId"=>456073223,
  #     "image"=>
  #     "http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg"},
  #   "totalvotes"=>"0",
  #   "videoUri"=>"http://api.myspace.com/v1/users/456073223/videos/53551799"}
end

