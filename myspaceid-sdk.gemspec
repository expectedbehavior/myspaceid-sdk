Gem::Specification.new do |s|
  s.name = "myspaceid-sdk"
  s.version = "0.1.11.2"
  s.summary = "SDK for MySpaceID and MySpace Data Accessibility."
  s.homepage = "http://github.com/expectedbehavior/myspaceid-sdk"
  s.description = "The MySpaceID SDK provides a library for implementing MySpaceID and accessing MySpace users account data."
  s.files = ["README", "lib/myspace", "lib/myspace/end_point.rb", "lib/myspace/exceptions.rb", "lib/myspace/myspace.rb", "lib/myspace/oauth_request.rb", "lib/myspace.rb", "lib/patches.rb", "test/myspace_test.rb", "test/tc_albums.rb", "test/tc_appdata.rb", "test/tc_friends.rb", "test/tc_profile.rb", "test/tc_videos.rb", "test/test_data.rb", "test/ts_alltests.rb"]

  s.add_dependency(%q{ruby-openid})
  s.add_dependency(%q{oauth})
  s.add_dependency(%q{json})
end
