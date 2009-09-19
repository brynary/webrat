module Webrat
  module Selenium
    module SilenceStream
      # active_support already defines silence_stream, no need to do that again if it's already present.
      # http://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/kernel/reporting.rb
      unless Kernel.respond_to?(:silence_stream)
        def silence_stream(stream)
          old_stream = stream.dup
          stream.reopen(RUBY_PLATFORM =~ /mswin/ ? 'NUL:' : '/dev/null')
          stream.sync = true
          yield
        ensure
          stream.reopen(old_stream)
        end
      end
    end
  end
end
