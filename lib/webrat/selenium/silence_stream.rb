module Webrat
  module Selenium
    module SilenceStream
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