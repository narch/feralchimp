$:.unshift(File.expand_path("../lib", __FILE__))
require "feralchimp/version"

Gem::Specification.new do |s|
  s.summary = "A simple API wrapper for Mailchimp."
  s.email = ["jordon@envygeeks.com"]
  s.version = Feralchimp::VERSION
  s.name = "feralchimp"
  s.license = "MIT"
  s.has_rdoc = false
  s.files = Dir["**/*"]
  s.require_paths = ["lib"]
  s.authors = ["Jordon Bedwell"]
  s.add_runtime_dependency("json", "~> 1.7.6")
  s.add_runtime_dependency("faraday", "~> 0.8.5")
  s.add_development_dependency("minitest", "~> 4.6")
  s.add_development_dependency("fakeweb", "~> 1.3.0")
  s.homepage = "http://envygeeks.com/projects/feralchimp/"
  s.description = "A simple API wrapper for Mailchimp that uses Faraday."
end
