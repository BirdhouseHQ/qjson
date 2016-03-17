$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "qjson/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "qjson"
  s.version     = QJSON::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Daniel Staudigel"]
  s.email       = ["dstaudigel@gmail.com"]
  s.homepage    = "http://github.com/thehumaneffort/qjson"
  s.summary     = "Summary of Qjson."
  s.description = "Description of Qjson."
  s.license     = "MIT"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency "rails", "> 3.2.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "riot"
end
