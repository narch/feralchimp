$:.unshift(File.expand_path("../../lib", __FILE__))
ENV["RACK_ENV"] = "test"

unless %W(no false).include?(ENV["COVERAGE"])
  require "simplecov"
  require "coveralls"

  module Coveralls
    NoiseBlacklist = [
      "[Coveralls] Using SimpleCov's default settings.".green,
      "[Coveralls] Set up the SimpleCov formatter.".green,
      "[Coveralls] Outside the Travis environment, not sending data.".yellow
    ]

    def puts(message)
      # Only prevent the useless noise on our terminals, not inside of the Travis or Circle CI.
      unless NoiseBlacklist.include?(message) || ENV["TRAVIS"] == "true" || ENV["CI"] == "true"
        $stdout.puts message
      end
    end
  end

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
        Coveralls::SimpleCov::Formatter
  ]

  Coveralls.noisy = true
  SimpleCov.start do
    add_filter "/spec/"
  end
end

MAILCHIMP_URL = %r!https://us6.api.mailchimp.com/1.3/\?method=(?:[a-z0-9]+)!
EXPORT_URL = %r!https://us6.api.mailchimp.com/export/1.0/(?:[a-z0-9]+)!
ERROR_URL = "https://us6.api.mailchimp.com/1.3/?method=error"

require "webmock/rspec"
require "feralchimp"
WebMock.disable_net_connect!

def get_stub_response(name)
  IO.read(File.expand_path("../../fixtures/#{name}.json", __FILE__))
end

def to_constant(name)
  Kernel.const_get(name.to_s.chars.map { |c| c.capitalize }.join)
end

def stub_response(name, const = to_constant(name))
  WebMock.stub_request(:any, const).to_return(body: get_stub_response(name))
end

module RSpecFixes
  def to_ary
    raise NoMethodError
  end
end

[FeralchimpErrorHash, Feralchimp].each do |c|
  c.send(:include, RSpecFixes)
end
