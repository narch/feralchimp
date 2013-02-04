$:.unshift(File.expand_path("../../lib", __FILE__))
require "pathname"

if ENV["COVERAGE"] == true
  require "simplecov"
  SimpleCov.command_name("minitest") and SimpleCov.start
end


BENCHMARK = true if (ENV["CI"] && RUBY_ENGINE != "rbx") || ENV["BENCHMARK"]
ROOT = Pathname.new(File.expand_path("../", __FILE__))

URLS = {
  export: %r!^https://us6.api.mailchimp.com/export/1.0/.*/!,
  error: "https://us6.api.mailchimp.com/1.3/?method=error",
  api: %r!^https://us6.api.mailchimp.com/1.3/\?method=.*!,
  export_bench: "https://us6.api.mailchimp.com/export/1.0/bench/"
}

DATA = {
  export: IO.read(ROOT.join("responses/export.txt")),
  error: IO.read(ROOT.join("responses/error.json")),
  api: IO.read(ROOT.join("responses/api.json")),
  export_bench: IO.read(ROOT.join("responses/bench.txt")),
}

require "minitest/benchmark"
require "minitest/autorun"
require "minitest/pride"
require "minitest/unit"
require "minitest/spec"
require "fakeweb"
require "feralchimp"

FakeWeb.allow_net_connect = false

FakeWeb.register_uri(:any, URLS[:error], :body => DATA[:error])
FakeWeb.register_uri(:any, URLS[:api], :body => DATA[:api])
FakeWeb.register_uri(:any, URLS[:export], :body => DATA[:export])
FakeWeb.register_uri(:any, URLS[:export_bench], :body => DATA[:export_bench])

describe Object do
  describe "#to_mailchimp_method" do
    describe "('test_method')"  do
      it "should return 'testMethod'"  do
        "test_method".to_mailchimp_method.must_equal("testMethod")
      end
    end

    describe "('testMethod')" do
      it "should return 'testMethod'" do
        "testMethod".to_mailchimp_method.must_equal("testMethod")
      end
    end
  end

  describe "#blank?" do
    it "should just work" do
      [{}.blank?, [].blank?, "".blank?].must_equal([true, true, true])
    end
  end
end

describe FeralchimpErrorHash do
  describe "#initialize" do
    describe "({ test: 1 })" do
      it "should return { test: 1 }" do
       FeralchimpErrorHash.new(test: 1).must_equal(test: 1)
      end
    end

    it "should return empty hash" do
      FeralchimpErrorHash.new.must_equal(Hash.new)
    end
  end

  describe "#method_missing" do
    it "should just work" do
      FeralchimpErrorHash.new.test1.must_equal(Hash.new)
    end
  end
end

if defined?(BENCHMARK) && BENCHMARK == true
  class FeralchimpTest < MiniTest::Unit::TestCase
    def setup
      Feralchimp.key = "a-us6"
    end

    def bench_feralchimp_api_calls
      assert_performance(Proc.new { |*args| }) { |n|
        n.times { Feralchimp.lists }
      }
    end

    def bench_feralchimp_export_calls
      assert_performance(Proc.new { |*args| }) { |n|
        n.times { Feralchimp.export.bench(id: 1) }
      }
    end
  end
end

describe Feralchimp do
  def teardown
    ENV.delete("MAILCHIMP_API_KEY")
    Feralchimp.class_eval {
      @timeout = nil
      @raise = nil
      @key = nil
      @exportar = nil
    }
  end

describe "VERSION" do
  it "should be proper" do
    Feralchimp::VERSION.must_match(/(\d+.)+(.pre\d{1})?/)
  end
end

describe ".method_missing" do
  describe "using a key set with key=" do
    it "should just work" do
      Feralchimp.key = "a-us6"
      Feralchimp.lists.must_equal("total" => 1)
    end
  end

  describe "using a key set while calling the API method" do
    it "should just work" do
      Feralchimp.lists(apikey: "a-us6").must_equal("total" => 1)
    end
  end
end

describe "#method_missing" do
  describe "using a key set while calling the API method" do
    it "should just work" do
      Feralchimp.new.lists(apikey: "a-us6").must_equal("total" => 1)
    end
  end

  describe "using a key set with key=" do
    it "should just work" do
      Feralchimp.key = "a-us6"
      Feralchimp.new.lists.must_equal("total" => 1)
    end
  end

  describe "using a key set while calling new" do
    it "should just work" do
      Feralchimp.new("a-us6").lists.must_equal("total" => 1)
    end
  end
end

describe "export" do
  it "should set exportar" do
    Feralchimp.export
    Feralchimp.exportar.must_be(:==, true)
  end

  it "should just work" do
    expected_out = [
      { "header1" => "return1", "header2" => "return2" },
      { "header1" => "return1", "header2" => "return2" }
    ]

    Feralchimp.export.list(apikey: "a-us6", id: 1).must_equal(expected_out)
end
  end

  describe ".exportar" do
    it "should be reset after each message" do
      Feralchimp.export.list(apikey: "a-us6", id: 1)
      Feralchimp.exportar.must_be(:==, false)
    end

    it "should not accept any arguments" do
      Feralchimp.raise = true
      Feralchimp.method(:exportar).arity.must_equal(0)
      Proc.new { Feralchimp.export(:some_arbitrary_argument) }.must_raise(ArgumentError)
    end
  end

  describe "key" do
    it "should be aliased over to api_key" do
      Feralchimp.must_respond_to(:api_key)
    end

    it "shoud be aliased over to api_key=" do
      Feralchimp.must_respond_to(:api_key=)
    end

    it "should make new(api_key) more important than key" do
      Feralchimp.new("b-us6").instance_variable_get(:@key).must_equal("b-us6")
    end
  end

  describe "raise" do
    describe "== true" do
      it "should raise the error" do
        Feralchimp.raise = true
        Proc.new { Feralchimp.list }.must_raise(Feralchimp::KeyError)
        Proc.new { Feralchimp.new("a-us6").error }.must_raise(Feralchimp::MailchimpError)
      end
    end

    describe "== false" do
      it "should return a hash" do
        error1 = Feralchimp.lists
        Feralchimp.key = "a-us6"
        error2 = Feralchimp.error

        Feralchimp.key = "a-us6"
        error1.must_be_kind_of(Hash)
        error2.must_be_kind_of(Hash)
        error1["error"].must_equal("Invalid key.")
        error2["error"].must_equal("You lost the game bro.")
      end
    end
  end
end
