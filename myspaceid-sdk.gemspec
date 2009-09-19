# require 'rubygems'
# require 'rake/packagetask'

# PKG_FILES = FileList[
#                      'README', 'lib/**/*', 'test/**/*', 'samples/**/*'
#                     ].exclude(/db\/cstore\/(associations|nonces)|log\//)

Gem::Specification.new do |s|
#   s.name = %q{myspaceid-sdk}
#   s.version = "0.1.8"
#   s.date = %q{2009-03-24}
#   s.authors = ["Christopher B. Baker"]
#   s.email = %q{cbaker@myspace.com}
#   s.require_paths = ["lib"]
#   s.summary = %q{Official SDK for MySpaceID and MySpace Data Accessibility.}
#   s.homepage = %q{http://developer.myspace.com/}
#   s.has_rdoc = true
#   s.description = %q{The MySpaceID SDK provides a library for implementing MySpaceID and accessing MySpace users account data.}
#   s.files = PKG_FILES
#   s.rubyforge_project = %q{myspaceid-sdk}

  s.add_dependency(%q{ruby-openid})
  s.add_dependency(%q{oauth})
  s.add_dependency(%q{json})
end
