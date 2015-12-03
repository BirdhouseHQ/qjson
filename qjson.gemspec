$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "qjson/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "qjson"
  s.version     = QJSON::VERSION
  s.authors     = ["Daniel Staudigel"]
  s.email       = ["dstaudigel@gmail.com"]
  s.homepage    = "https://github.com/TheHumanEffort/qjson"
  s.summary     = "QJSON is a rails gem for quickly serializing and deserializing JSON."
  s.description = "qjson aims to solve the majority of json serialization issues in a way that is performant, expressive, and open to the complexities of long-term API management."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.4"

  # s.add_development_dependency "sqlite3"
end
