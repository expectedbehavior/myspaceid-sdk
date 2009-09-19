require 'test/unit'
require 'myspace'

class TC_AppData < Test::Unit::TestCase
  include MySpaceTest

  def test_global
    obj = nil
    [@ms_offsite, @ms_onsite].each do |ms|
      assert_nothing_raised do
        obj = ms.get_global_appdata
      end
      assert_instance_of(Hash, obj)

      assert_nothing_raised do
        ms.set_global_appdata(:ruby_test => "updating!")
      end

      assert_passes_eventually do |result|
        assert_nothing_raised do
          obj = ms.get_global_appdata(:ruby_test)
        end
        assert_instance_of(Hash, obj)
        result.passed = true if obj.keys.length == 1
      end

      assert_nothing_raised do
        ms.clear_global_appdata(:ruby_test)
      end

      assert_passes_eventually do |result|
        assert_nothing_raised do
          obj = ms.get_global_appdata(:ruby_test)
        end
        assert_instance_of(Hash, obj)
        result.passed = true if obj.keys.length == 0
      end
    end
  end

  def test_user
    obj = nil
    [@ms_offsite, @ms_onsite].each do |ms|
      assert_nothing_raised do
        obj = ms.get_user_appdata(USER_ID)
      end
      assert_instance_of(Hash, obj)

      assert_nothing_raised do
        ms.set_user_appdata(USER_ID, :user_test => "updating!")
      end

      assert_passes_eventually do |result|
        assert_nothing_raised do
          obj = ms.get_user_appdata(USER_ID, :user_test)
        end
        assert_instance_of(Hash, obj)
        result.passed = true if obj.keys.length == 1
      end

      assert_nothing_raised do
        ms.clear_user_appdata(USER_ID, :user_test)
      end

      assert_passes_eventually do |result|
        assert_nothing_raised do
          obj = ms.get_user_appdata(USER_ID, :user_test)
        end
        assert_instance_of(Hash, obj)
        result.passed = true if obj.keys.length == 0
      end
    end
    # assert_nothing_raised do 
    #   obj = @ms_onsite.get_user_friends_appdata(USER_ID)
    # end
    # assert_instance_of(Hash, obj)
    # assert(true, obj.has_key?('146617378'))
    # user_data = obj['146617378']
    # assert_instance_of(Hash, user_data)
    # assert(true, obj.has_key?(:test_key))
    # user_value = user_data[:test_key]
    # assert_instance_of(String, user_value)
    # assert_equal("some test data", user_value)
  end
end
