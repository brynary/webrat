require "rubygems"

begin
  require 'spec/rake/spectask'
rescue LoadError
  desc "Run specs"
  task(:spec) { $stderr.puts '`gem install rspec` to run specs' }
else
  desc "Run API and Core specs"
  Spec::Rake::SpecTask.new do |t|
    t.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
    t.spec_files = FileList['spec/public/**/*_spec.rb'] + FileList['spec/private/**/*_spec.rb']
  end

  desc "Run all specs in spec directory with RCov"
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
    t.spec_files = FileList['spec/public/**/*_spec.rb'] + FileList['spec/private/**/*_spec.rb']
    t.rcov = true
    t.rcov_opts = lambda do
      IO.readlines(File.dirname(__FILE__) + "/spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
    end
  end
end

desc "Run everything against multiruby"
task :multiruby do
  result = system "multiruby -S rake spec"
  raise "Multiruby tests failed" unless result
  result = system "jruby -S rake spec"
  raise "JRuby tests failed" unless result

  Dir.chdir "spec/integration/rails" do
    result = system "multiruby -S rake test_unit:rails"
    raise "Rails integration tests failed" unless result

    result = system "jruby -S rake test_unit:rails"
    raise "Rails integration tests failed" unless result
  end

  Dir.chdir "spec/integration/merb" do
    result = system "multiruby -S rake spec"
    raise "Merb integration tests failed" unless result

    result = system "jruby -S rake spec"
    raise "Rails integration tests failed" unless result
  end

  Dir.chdir "spec/integration/sinatra" do
    result = system "multiruby -S rake test"
    raise "Sinatra integration tests failed" unless result

    result = system "jruby -S rake test"
    raise "Sinatra integration tests failed" unless result
  end

  Dir.chdir "spec/integration/rack" do
    result = system "multiruby -S rake test"
    raise "Rack integration tests failed" unless result

    result = system "jruby -S rake test"
    raise "Rack integration tests failed" unless result
  end

  puts
  puts "Multiruby OK!"
end

desc "Run each spec in isolation to test for dependency issues"
task :spec_deps do
  Dir["spec/**/*_spec.rb"].each do |test|
    if !system("spec #{test} &> /dev/null")
      puts "Dependency Issues: #{test}"
    end
  end
end

namespace :spec do
  desc "Run the integration specs"
  task :integration => [
    "integration:rack",
    "integration:sinatra",
    "integration:merb",
    "integration:mechanize",
    "integration:rails:webrat",
    "integration:rails:selenium",
  ]

  namespace :integration do
    namespace :rails do
      task :selenium do
        Dir.chdir "spec/integration/rails" do
          result = system "rake test_unit:selenium"
          raise "Rails integration tests failed" unless result
        end
      end

      task :webrat do
        Dir.chdir "spec/integration/rails" do
          result = system "rake test_unit:rails"
          raise "Rails integration tests failed" unless result
        end
      end
    end

    desc "Run the Merb integration specs"
    task :merb do
      Dir.chdir "spec/integration/merb" do
        result = system "rake spec"
        raise "Merb integration tests failed" unless result
      end
    end

    desc "Run the Sinatra integration specs"
    task :sinatra do
      Dir.chdir "spec/integration/sinatra" do
        result = system "rake test"
        raise "Sinatra integration tests failed" unless result
      end
    end

    desc "Run the Sinatra integration specs"
    task :rack do
      Dir.chdir "spec/integration/rack" do
        result = system "rake test"
        raise "Rack integration tests failed" unless result
      end
    end

    desc "Run the Mechanize integration specs"
    task :mechanize do
      Dir.chdir "spec/integration/mechanize" do
        result = system "rake spec"
        raise "Mechanize integration tests failed" unless result
      end
    end
  end
end

desc 'Removes trailing whitespace'
task :whitespace do
  sh %{find . -name '*.rb' -exec sed -i '' 's/ *$//g' {} \\;}
end

task :default => :spec