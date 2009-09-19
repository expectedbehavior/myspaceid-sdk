require 'test/unit'
require 'myspace'

class TC_Friends < Test::Unit::TestCase
  include MySpaceTest

  def test_friends
    obj = nil
    assert_raise(OAuth::Problem) do
      obj = @ms_offsite.get_friends("6221")
    end
    assert_raise(MySpace::PermissionDenied) do
      obj = @ms_onsite.get_friends("6221")
    end
    [@ms_offsite, @ms_onsite].each do |ms|
      BAD_IDS.each do |value|
        assert_raise(MySpace::BadIdentifier) do
          obj = ms.get_friends(value)
        end
      end
      assert_nothing_raised do
        obj = ms.get_friends(USER_ID)
      end
      count = obj['count']
      assert_instance_of(Fixnum, count)
      assert_equal(2, count)
      friends = obj['Friends']
      assert_instance_of(Array, friends)
      assert_equal(count, friends.length)
      tom = friends[0]
      name = tom['name']
      assert_instance_of(String, name)
      assert_equal('Tom', name)
      userid = tom['userId'].to_s
      assert_equal("6221", userid)
    end
  end
  # {"topFriends"=>"http://api.myspace.com/v1/users/456073223/friends?list=top",
  #   "Friends"=>
  #   [{"name"=>"Tom",
  #      "uri"=>"http://api.myspace.com/v1/users/6221",
  #      "webUri"=>"http://www.myspace.com/tom",
  #      "largeImage"=>"http://b2.ac-images.myspacecdn.com/00000/20/52/2502_l.jpg",
  #      "userType"=>"RegularUser",
  #      "userId"=>6221,
  #      "image"=>"http://b2.ac-images.myspacecdn.com/00000/20/52/2502_s.jpg"}],
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

  def test_friendship
    obj = nil
    [@ms_offsite, @ms_onsite].each do |ms|
      BAD_IDS.each do |value|
        assert_raise(MySpace::BadIdentifier) do
          obj = ms.get_friendship(USER_ID, value, "12341234", "456073223")
        end
      end
      BAD_IDS.each do |value|
        assert_raise(MySpace::BadIdentifier) do
          obj = ms.get_friendship(USER_ID, 6221, value, "456073223")
        end
      end
      BAD_IDS.each do |value|
        assert_raise(MySpace::BadIdentifier) do
          obj = ms.get_friendship(USER_ID, 6221, "12341234", value)
        end
      end

      assert_nothing_raised do
        obj = ms.get_friendship(USER_ID, 6221, "12341234", "456073223")
      end
      friendship = obj['friendship']
      assert_instance_of(Array, friendship)
      assert_equal(3, friendship.length)
      assert_equal(true, friendship[0]['areFriends'])
      assert_equal(false, friendship[1]['areFriends'])
      assert_equal(true, friendship[2]['areFriends'])
    end
  end

  # {"friendship"=>
  #   [{"areFriends"=>true, "friendId"=>6221},
  #    {"areFriends"=>false, "friendId"=>12341234},
  #    {"areFriends"=>true, "friendId"=>456073223}],
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
