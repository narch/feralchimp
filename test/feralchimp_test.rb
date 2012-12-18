$:.unshift(File.expand_path("../../lib", __FILE__))
COVERAGE, BENCHMARK = true, false

# Protects against undef(nil)..
unless ENV["COVERAGE"] == false || COVERAGE == false
  require "simplecov"
  SimpleCov.command_name("minitest") and SimpleCov.start
end

EXPORT_DATA = IO.read(File.expand_path("../responses/export.txt", __FILE__))
API_DATA = IO.read(File.expand_path("../responses/api.json", __FILE__))
API_MATCH = %r!^https://us6.api.mailchimp.com/1.3/\?method=.*!
EXPORT_MATCH = %r!^https://us6.api.mailchimp.com/export/1.0/.*/!

require "minitest/benchmark"
require "minitest/autorun"
require "minitest/pride"
require "minitest/unit"
require "fakeweb"
require "pry"
require "feralchimp"

FakeWeb.register_uri(:any, EXPORT_MATCH, :body => EXPORT_DATA)
FakeWeb.register_uri(:any, API_MATCH, :body => API_DATA)
FakeWeb.allow_net_connect = false

class ObjectTest < MiniTest::Unit::TestCase
  def test_to_mailchimp_method
    assert_equal("testMethod", "test_method".to_mailchimp_method)
  end

  def test_blank?
    assert("".blank?)
  end
end

class FeralchimpErrorHashTest < MiniTest::Unit::TestCase
  def test_initialize
    assert_equal({}, FeralchimpErrorHash.new)
    assert_equal({ test: 1 }, FeralchimpErrorHash.new({ test: 1 }))
  end
end

class FeralchimpTest < MiniTest::Unit::TestCase
  def teardown
    ENV.delete("MAILCHIMP_API_KEY")
    Feralchimp.class_eval {
      @raise = false
      @key = false
      @timeout = false
      @exportar = false
    }
  end

  if ENV["BENCHMARK"] || BENCHMARK
    def bench_feralchimp_api_calls
      Feralchimp.key = "a-us6"
      assert_performance(Proc.new { |*args| }) { |n|
        n.times {
          Feralchimp.lists
        }
      }
    end
  end

  if ENV["BENCHMARK"] || BENCHMARK
    def bench_feralchimp_export_calls
      Feralchimp.key = "a-us6"
      assert_performance(Proc.new { |*args| }) { |n|
        n.times {
          Feralchimp.export.list(id: 1)
        }
      }
    end
  end

  def test_version
    assert_match(%r!(\d+.)+(.pre\d{1})?!, Feralchimp::VERSION)
  end

  def test_method_missing_api
    Feralchimp.key = "a-us6"
    assert_kind_of(Hash, Feralchimp.lists)
    assert_equal({ "total" => 1 }, Feralchimp.lists)
  end

  def test_method_missing_instance_api
    Feralchimp.key = "a-us6"
    assert_kind_of(Hash, Feralchimp.new.lists)
    assert_equal({ "total" => 1 }, Feralchimp.new.lists)
  end

  def test_method_missing_instance_api
    assert_kind_of(Hash, Feralchimp.new("a-us6").lists)
    assert_equal({ "total" => 1 }, Feralchimp.new("a-us6").lists)
  end

  def test_method_missing_export
    Feralchimp.key = "a-us6"
    Feralchimp.raise = true
    expected_out = [
      { "header1" => "return1", "header2" => "return2" },
      { "header1" => "return1", "header2" => "return2" }
    ]

    assert_kind_of(Array, Feralchimp.export.list(id: 1))
    refute(Feralchimp.exportar) # Tests the rest, yes.
    assert_equal(expected_out, Feralchimp.export.list(id: 1))
  end

  def test_raise=
    assert_kind_of(FeralchimpErrorHash, Feralchimp.export(1).list(id: 1))
    assert_kind_of(FeralchimpErrorHash, Feralchimp.lists)

    Feralchimp.raise = true
    assert_raises(Feralchimp::KeyError) { Feralchimp.lists }
    assert_raises(ArgumentError) { Feralchimp.export(1).list(id: 1) }
  end

  def test_key=
    Feralchimp.key = "a-us6"
    assert_equal("a-us6", Feralchimp.key)
    assert_equal("a-us6", Feralchimp.new.instance_variable_get(:@key))
    assert_equal("b-us6", Feralchimp.new("b-us6").instance_variable_get(:@key))
  end
end
