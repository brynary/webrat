require "webrat/core/matchers/have_selector"

module Webrat
  module HaveTagMatcher

    def have_tag(*args, &block)
      have_selector(*args, &block)
    end

    alias_method :match_tag, :have_tag

    def assert_have_tag(*args, &block)
      assert_have_selector(*args, &block)
    end

    def assert_have_no_tag(*args, &block)
      assert_have_no_selector(*args, &block)
    end

  end
end
