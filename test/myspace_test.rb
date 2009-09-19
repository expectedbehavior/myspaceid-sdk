require 'test/unit'

require 'myspace'

require 'test_data'

module MySpaceTest
  include TestData

  def setup
    @ms_offsite = MySpace::MySpace.new(OFFSITE_KEY, OFFSITE_SECRET,
                                       :access_token => TOKEN, :access_token_secret => SECRET,
                                       :logger => Logger.new($stdout))
    @ms_onsite = MySpace::MySpace.new(ONSITE_KEY, ONSITE_SECRET, :application_type => MySpace::MySpace::APPLICATION_TYPE_ONSITE,
                                      :logger => Logger.new($stdout))
  end

  class Tester
    attr_accessor :passed
    def initialize(default = false)
      @passed = default
    end
  end

  def assert_passes_eventually(max_iterations = 10, sleep_time = 0.1, &block)
    tester = Tester.new
    max_iterations.times do
      yield(tester)
      break if tester.passed
      sleep(sleep_time)
    end
    assert(tester.passed)
  end

end
