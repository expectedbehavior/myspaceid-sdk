require 'rubygems'
require 'rake/packagetask'

PKG_FILES = FileList[
                      'README', 'lib/**/*', 'test/**/*', 'samples/**/*'
                     ].exclude(/db\/cstore\/(associations|nonces)|log\//)

Gem::Specification.new do |s|
  s.name = "myspaceid-sdk"
  s.version = "0.1.11.1"
  s.summary = "SDK for MySpaceID and MySpace Data Accessibility."
  s.homepage = "http://github.com/expectedbehavior/myspaceid-sdk"
  s.description = "The MySpaceID SDK provides a library for implementing MySpaceID and accessing MySpace users account data."
  s.files = PKG_FILES

  s.add_dependency(%q{ruby-openid})
  s.add_dependency(%q{oauth})
  s.add_dependency(%q{json})
end
