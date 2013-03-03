require "simplecov"
SimpleCov.start

MAILCHIMP_URL = %r!https://us6.api.mailchimp.com/1.3/\?method=(?:[a-z0-9]+)!
EXPORT_URL = %r!https://us6.api.mailchimp.com/export/1.0/(?:[a-z0-9]+)!
ERROR_URL = "https://us6.api.mailchimp.com/1.3/?method=error"

require "webmock/rspec"
require "feralchimp"
WebMock.disable_net_connect!

def get_stub_response(name)
  IO.read(File.expand_path("../../responses/#{name}.json", __FILE__))
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
