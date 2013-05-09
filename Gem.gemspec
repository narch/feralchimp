$:.unshift(File.expand_path("../lib", __FILE__))
require "feralchimp/version"

Gem::Specification.new do |spec|
  spec.summary = "A simple API wrapper for Mailchimp."
  spec.email = ["envygeeks@gmail.com"]
  spec.version = Feralchimp::VERSION
  spec.name = "feralchimp"
  spec.license = "MIT"
  spec.has_rdoc = false
  spec.files = Dir["**/*"]
  spec.require_paths = ["lib"]
  spec.authors = ["Jordon Bedwell"]
  spec.add_runtime_dependency("json", "~> 1.7.7")
  spec.add_runtime_dependency("faraday", "~> 0.8.6")
  spec.add_development_dependency("rspec", "~> 2.13.0")
  spec.add_development_dependency("webmock", "~> 1.10.1")
  spec.homepage = "http://envygeeks.com/projects/feralchimp/"
  spec.description = "A simple API wrapper for Mailchimp that uses Faraday."
end
