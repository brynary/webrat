require 'rubygems'
require 'benchmark'
require 'spec'
require 'spec/runner/formatter/base_text_formatter'
require 'spec/spec_helper.rb'

# Load this stuff so it only has to be loaded once for the entire suite
require 'spec/mocks'
require 'spec/mocks/extensions'
require 'spec/runner/formatter/specdoc_formatter'
require 'base64'
require 'nkf'
require 'kconv'
require 'rack'
require 'fileutils'

begin
  require 'json'
rescue
  require 'json/pure'
end

Merb::Dispatcher

module Merb
  class Counter

    attr_accessor :time
    def initialize
      @examples, @failures, @errors, @pending, @total_time = 0, 0, 0, 0, 0
      @err = ""
      @mutex = Mutex.new
    end
  
    def failed?
      @failures > 0
    end
  
    def add(spec, out, err)
      @mutex.synchronize do
        puts
        puts "Running #{spec}."
        STDOUT.puts out
        STDOUT.flush
        match = out.match(/(\d+) examples?, (\d+) failures?(?:, (\d+) errors?)?(?:, (\d+) pending?)?/m)
        time = out.match(/Finished in (\d+\.\d+) seconds/)
        @total_time += time[1].to_f if time
        if match
          e, f, errors, pending = match[1..-1]
          @examples += e.to_i
          @failures += f.to_i
          @errors += errors.to_i
          @pending += pending.to_i
        end
        unless err.chomp.empty?
          @err << err.chomp << "\n"
        end
      end
    end

    def report
      i = 0
      @err.gsub!(/^\d*\)\s*/) do
        "#{i += 1})\n"
      end
      
      puts @err
      puts
      if @failures != 0 || @errors != 0
        print "\e[31m" # Red
      elsif @pending != 0
        print "\e[33m" # Yellow
      else
        print "\e[32m" # Green
      end
      puts "#{@examples} examples, #{@failures} failures, #{@errors} errors, #{@pending} pending, #{sprintf("suite run in %3.3f seconds", @time.real)}"
      # TODO: we need to report pending examples all together
       puts "\e[0m"    
    end  
  end
end

require File.dirname(__FILE__) / "run_spec"

# Runs specs in all files matching the file pattern.
#
def run_specs(globs)
  require "optparse"
  require "spec"
  globs = globs.is_a?(Array) ? globs : [globs]
  
  forking = (ENV["FORK"] ? ENV["FORK"] == "1" : Merb.forking_environment?)
  base_dir = File.expand_path(File.dirname(__FILE__) / ".." / ".." / "..")
  
  counter = Merb::Counter.new
  forks   = 0
  failure = false

  FileUtils.rm_rf(File.join(base_dir, "results"))
  FileUtils.mkdir_p(File.join(base_dir, "results"))

  time = Benchmark.measure do
    files = {}
    globs.each do |glob|
      Dir[glob].each do |spec|
        if forking
          Kernel.fork do
            run_spec(spec, base_dir)
          end
          Process.wait
        else
          `NOW=1 #{Gem.ruby} #{File.dirname(__FILE__) / "run_spec.rb"} \"#{spec}\"`
        end
        out = File.read(File.join(base_dir, "results", "#{File.basename(spec)}_out"))
        err = File.read(File.join(base_dir, "results", "#{File.basename(spec)}_err"))
        counter.add(spec, out, err)        
      end
    end
  end
  
  Process.waitall
  
  counter.time = time
  counter.report
  FileUtils.rm_rf(File.join(base_dir, "results"))
  exit!(counter.failed? ? -1 : 0)
end
