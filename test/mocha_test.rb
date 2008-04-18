require File.dirname(__FILE__) + "/helper"

RAILS_ROOT = "." unless defined?(RAILS_ROOT)

class FooThing
end

class MochaTest < Test::Unit::TestCase
  def test_mocha
    @foo = FooThing.new
    @foo.stubs(:bar).returns("bar")
    assert_equal @foo.bar, "bar"
  end
end
