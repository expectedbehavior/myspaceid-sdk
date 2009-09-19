require 'test/unit'

require 'myspace'

require 'myspace_test'

class TC_Profile < Test::Unit::TestCase
  include MySpaceTest

  def test_userid
    user_id = nil
    assert_nothing_raised do
      user_id = @ms_offsite.get_userid
    end
    assert_instance_of(String, user_id)
    assert_equal(USER_ID, user_id)
  end

  def test_profile
    [@ms_offsite, @ms_onsite].each do |ms|
    obj = nil
    BAD_IDS.each do |value|
      assert_raise(MySpace::BadIdentifier) do
        obj = ms.get_profile(value)
      end
    end
    assert_nothing_raised do
      obj = ms.get_profile(USER_ID)
    end
    assert_instance_of(Hash, obj)
    basic_profile = obj['basicprofile']
    assert_instance_of(Hash, basic_profile)
    name = basic_profile['name']
    assert_instance_of(String, name)
    assert_equal("Bob", name)
    uri = basic_profile['uri']
    assert_instance_of(String, uri)
    assert_equal("http://api.myspace.com/v1/users/456073223", uri)
    web_uri = basic_profile['webUri']
    assert_instance_of(String, web_uri)
    assert_equal("http://www.myspace.com/bobvontestacount", web_uri)
    large_image = basic_profile['largeImage']
    assert_instance_of(String, large_image)
    assert_equal("http://c1.ac-images.myspacecdn.com/images02/45/l_f820313641924f0f90004932c8bc310c.jpg", large_image)
    image = basic_profile['image']
    assert_instance_of(String, image)
    assert_equal("http://c1.ac-images.myspacecdn.com/images02/45/s_f820313641924f0f90004932c8bc310c.jpg", image)
    end
  end

  def test_mood
    [@ms_offsite, @ms_onsite].each do |ms|
      obj = nil
      BAD_IDS.each do |value|
        assert_raise(MySpace::BadIdentifier) do
          obj = ms.get_mood(value)
        end
      end
      assert_nothing_raised do
        obj = ms.get_mood(USER_ID)
      end
      assert_instance_of(Hash, obj)
      mood = obj['mood']
      assert_instance_of(String, mood)
      # assert_equal("tested", mood)
      # mood_image = obj['moodImageUrl']
      # assert_instance_of(String, mood_image)
      # assert_equal("http://x.myspacecdn.com/images/blog/moods/iBrads/confused.gif", mood_image)
    end
  end

  def test_status
    [@ms_offsite, @ms_onsite].each do |ms|
      obj = nil
      BAD_IDS.each do |value|
        assert_raise(MySpace::BadIdentifier) do
          obj = ms.get_status(value)
        end
      end
      assert_nothing_raised do
        obj = ms.get_status(USER_ID)
      end
      assert_instance_of(Hash, obj)
      status = obj['status']
      assert_instance_of(String, status)
      # assert_equal("Testing", status)

      assert_nothing_raised do
        ms.set_status(USER_ID, "Updating!")
      end

      assert_passes_eventually do |result|
        assert_nothing_raised do
          obj = ms.get_status(USER_ID)
        end
        assert_instance_of(Hash, obj)
        status = obj['status']
        assert_instance_of(String, status)
        result.passed = true if status == "Updating!"
      end

      assert_nothing_raised do
        ms.set_status(USER_ID, "Testing")
      end
    end
  end
end
