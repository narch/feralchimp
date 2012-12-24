$:.unshift("../../lib", __FILE__) if __FILE__ == $0
require "feralchimp/version"
require "faraday"
require "json"
require "uri"
require "cgi"

# Allow for export(1).list flow.
class FeralchimpErrorHash < Hash
  def initialize(hash = nil)
    if hash.is_a?(Hash)
      hash.each { |k, v|
        self[k] = v
      }

      return self
    end

  super
  end

  def method_missing(method, *args, &block)
    return self
  end
end

class Object
  def to_mailchimp_method
    self.to_s.gsub(/_(.)/) { $1.capitalize }
  end

  def blank?
    respond_to?(:empty?) ? (empty?) : (!self)
  end
end

class Feralchimp
  @exportar = false
  @timeout = 5
  @raise = false
  @key = ENV["MAILCHIMP_API_KEY"]

  [:MethodError, :KeyError].each { |o|
    const_set(o, Class.new(StandardError))
  }

  def initialize(key = nil)
    @key = key || self.class.key
  end

  def method_missing(method, *args, &block)
    begin
      if method == :export
        if args.count > 0
          raise ::ArgumentError, "#{args.count} for 0"
        end

        self.class.exportar = true
        return self # Oh, trickey!
      end

      call(method, *args)
    rescue => error
      if self.class.raise
        raise error
      else
        FeralchimpErrorHash.new({
          "object" => error,
          "code" => 9001,
          "error" => error.message
        })
      end
    end
  end

  private
  def call(method, bananas = {}, export = self.class.exportar)
    raise MethodError, "No method provided." if method.blank?

    key = parse_key(bananas.delete(:apikey) || @key)
    self.class.exportar = false
    method = method.to_mailchimp_method

    ::Faraday.new(:url => api_url(key.last)) { |o|
      o.response(export ? :json_export : :json)
      o.options[:timeout] = self.class.timeout
      o.request(:url_encoded)
      o.adapter(Faraday.default_adapter)
    }.post(api_path(export) % method, bananas.merge(apikey: key.first)).body
  end

  private
  def parse_key(key)
    if key =~ %r!\w+-{1}[a-z]{2}\d{1}!
      key.split("-")
    else raise KeyError, "Invalid key: #{key}." end
  end

  private
  def api_path(export = false)
    if !export
      "/1.3/?method=%s"
    # Trail is important yo...
    else "/export/1.0/%s/" end
  end

  private
  def api_url(zone)
    URI.parse("https://#{zone}.api.mailchimp.com")
  end

  class << self
    attr_accessor :exportar, :raise, :timeout, :key
    def method_missing(method, *args, &block)
      new.send(*args.unshift(method))
    end

    # Minitest
    def to_str
      to_s
    end
  end

  module Response
    class JSON < Faraday::Middleware
      def call(environment)
        @app.call(environment).on_complete { |env|
          env[:raw_body] = env[:body]
          env[:body] =
            ::JSON.parse("[" + env[:raw_body].to_s + "]").first
        }
      end
    end

    class JSONExport < Faraday::Middleware
      def call(environment)
        @app.call(environment).on_complete { |env|
          env[:raw_body] = env[:body]

          body = env[:body].each_line.to_a
          keys = ::JSON.parse(body.shift)
          env[:body] = body.inject([]) { |a, k|
            a.push(Hash[keys.zip(::JSON.parse(k))])
          }
        }
      end
    end
  end
end

Faraday.register_middleware(:response, json: lambda { ::Feralchimp::Response::JSON })
Faraday.register_middleware(:response, json_export: lambda { ::Feralchimp::Response::JSONExport })
