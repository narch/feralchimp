$:.unshift(File.expand_path("../lib", __FILE__))
require "feralchimp/version"

Gem::Specification.new do |s|
  s.email = ["jordon@envygeeks.com"]
  s.version = Feralchimp::VERSION
  s.homepage = Feralchimp::URL
  s.name = "feralchimp"
  s.license = "MIT"
  s.has_rdoc = false
  s.files = Dir["**/*"]
  s.require_paths = ["lib"]
  s.authors = ["Jordon Bedwell"]
  s.add_runtime_dependency("json")
  s.add_runtime_dependency("faraday")
  s.add_development_dependency("pry")
  s.add_development_dependency("rake")
  s.add_development_dependency("fakeweb")
  s.add_development_dependency("minitest")
  s.add_development_dependency("simplecov")
  s.add_development_dependency("guard-minitest")
  s.summary = "A simple API wrapper for Mailchimp."
  s.description = "A simple API wrapper for Mailchimp that uses Faraday."
end
