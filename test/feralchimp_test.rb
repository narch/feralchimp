$:.unshift(File.expand_path("../../lib", __FILE__))
COVERAGE, BENCHMARK = true, false
require "simplecov"
unless ENV["COVERAGE"] == false || COVERAGE == false
  SimpleCov.command_name("minitest") and SimpleCov.start
end

ERROR_MATCH = "https://us6.api.mailchimp.com/1.3/?method=error"
API_MATCH = %r!^https://us6.api.mailchimp.com/1.3/\?method=.*!
EXPORT_MATCH = %r!^https://us6.api.mailchimp.com/export/1.0/.*/!

EXPORT_DATA = IO.read(File.expand_path("../responses/export.txt", __FILE__))
API_DATA = IO.read(File.expand_path("../responses/api.json", __FILE__))
ERROR_DATA = IO.read(File.expand_path("../responses/error.json", __FILE__))

require "minitest/benchmark"
require "minitest/autorun"
require "minitest/pride"
require "minitest/unit"
require "minitest/spec"
require "fakeweb"
require "pry"
require "feralchimp"

FakeWeb.allow_net_connect = false

FakeWeb.register_uri(:any, ERROR_MATCH, :body => ERROR_DATA)
FakeWeb.register_uri(:any, API_MATCH, :body => API_DATA)
FakeWeb.register_uri(:any, EXPORT_MATCH, :body => EXPORT_DATA)

describe(Object) {
  describe("#to_mailchimp_method") {
    describe("('test_method')") {
      it("should return 'testMethod'") {
        assert_equal("testMethod", "test_method".to_mailchimp_method)
      }
    }

    describe("('testMethod')") {
      it("should return 'testMethod'") {
        assert_equal("testMethod", "testMethod".to_mailchimp_method)
      }
    }
  }

  describe("#blank?") {
    it("should just work") {
      assert_equal([true, true, true], [{}.blank?, [].blank?, "".blank?])
    }
  }
}

describe(FeralchimpErrorHash) {
  describe("#initialize") {
    describe("({ test: 1 })") {
      it("should return { test: 1 }") {
        assert_equal({ test: 1 }, FeralchimpErrorHash.new({ test: 1 }))
      }
    }

    it("should return { }") {
      assert_equal({}, FeralchimpErrorHash.new)
    }
  }

  describe("#method_missing") {
    it("should just work") {
      assert_equal({}, FeralchimpErrorHash.new.test1)
    }
  }
}

describe(Feralchimp) {
  def teardown
    ENV.delete("MAILCHIMP_API_KEY")
    Feralchimp.class_eval {
      @timeout = nil
      @raise = nil
      @key = nil
      @exportar = nil
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

  describe("VERSION") {
    it("should be proper") {
      assert_match(%r!(\d+.)+(.pre\d{1})?!, Feralchimp::VERSION)
    }
  }

  describe(".method_missing") {
    describe("using a key set with key=") {
      it("should just work") {
        Feralchimp.key = "a-us6"
        assert_equal({ "total" => 1 }, Feralchimp.lists)
      }
    }

    describe("using a key set while calling the API method") {
      it("should just work") {
        assert_equal({ "total" => 1 }, Feralchimp.lists(apikey: "a-us6"))
      }
    }
  }

  describe("#method_missing") {
    describe("using a key set while calling the API method") {
      it("should just work") {
        assert_equal({ "total" => 1 }, Feralchimp.new.lists(apikey: "a-us6"))
      }
    }

    describe("using a key set with key=") {
      it("should just work") {
        Feralchimp.key = "a-us6"
        assert_equal({ "total" => 1 }, Feralchimp.new.lists)
      }
    }

    describe("using a key set while calling new") {
      it("should just work") {
        assert_equal({ "total" => 1 }, Feralchimp.new("a-us6").lists)
      }
    }
  }

  describe("export") {
    it("should set exportar") {
      Feralchimp.export
      assert(Feralchimp.exportar)
    }

    it("should just work") {
      expected_out = [
        { "header1" => "return1", "header2" => "return2" },
        { "header1" => "return1", "header2" => "return2" }
      ]

      assert_equal(expected_out, Feralchimp.export.list(apikey: "a-us6", id: 1))
    }
  }

  describe(".exportar") {
    it("should be reset after each call") {
      Feralchimp.export.list(apikey: "a-us6", id: 1)
      refute(Feralchimp.exportar)
    }

    it("should not accept any arguments") {
      Feralchimp.raise = true
      assert_raises(ArgumentError) { Feralchimp.export(:win).list }
    }
  }

  describe("key") {
    it("should be aliased over to api_key") {
      assert(Feralchimp.respond_to?(:api_key))
    }

    it("shoud be aliased over to api_key=") {
      assert(Feralchimp.respond_to?(:api_key=))
    }

    it("should make new(api_key) more important than key") {
      assert_equal("b-us6", Feralchimp.new("b-us6").instance_variable_get(:@key))
    }
  }

  describe("raise") {
    describe("== true") {
      it("should raise the error") {
        Feralchimp.raise = true
        assert_raises(Feralchimp::KeyError) { Feralchimp.list }
        assert_raises(Feralchimp::MailchimpError) { Feralchimp.new("a-us6").error }
      }
    }

    describe("== false") {
      it("should return a hash") {
        error1 = Feralchimp.lists
        Feralchimp.key = "a-us6"
        error2 = Feralchimp.error

        assert_kind_of(Hash, error1)
        assert_kind_of(Hash, error2)
        assert_equal("Invalid key.", error1["error"])
        assert_equal("You lost the game bro.", error2["error"])
      }
    }
  }
}
