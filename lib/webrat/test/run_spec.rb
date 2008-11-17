require "stringio"
require 'rubygems'
require 'spec'
require 'spec/runner/formatter/specdoc_formatter'

module Spec
  module Runner
    module Formatter
      class BaseTextFormatter
        def dump_failure(counter, failure)
          output = @options.error_stream
          output.puts
          output.puts "#{counter.to_s})"
          output.puts colourise("#{failure.header}\n#{failure.exception.message}", failure)
          output.puts format_backtrace(failure.exception.backtrace)
          output.flush
        end
      end
    end
  end
end

def run_spec(spec, base_dir)

  $VERBOSE = nil
  err, out = StringIO.new, StringIO.new
  def out.tty?() true end
  options = Spec::Runner::OptionParser.parse(%W(#{spec} -fs --color), err, out)
  options.filename_pattern = File.expand_path(spec)
  failure = ! Spec::Runner::CommandLine.run(options)
  File.open(File.join(base_dir, "results", "#{File.basename(spec)}_out"), "w") do |file|
    file.puts out.string
  end
  File.open(File.join(base_dir, "results", "#{File.basename(spec)}_err"), "w") do |file|
    file.puts err.string
  end
  exit!(failure ? -1 : 0)
end

run_spec(ARGV[0], File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))) if ENV["NOW"]
