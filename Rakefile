require 'rubygems'
require "rake/gempackagetask"
require 'rake/rdoctask'
require "rake/clean"
require 'spec'
require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'
require File.expand_path('./lib/webrat.rb')

##############################################################################
# Package && release
##############################################################################
spec = Gem::Specification.new do |s|
  s.name         = "webrat"
  s.version      = Webrat::VERSION
  s.platform     = Gem::Platform::RUBY
  s.author       = "Bryan Helmkamp"
  s.email        = "bryan" + "@" + "brynary.com"
  s.homepage     = "http://github.com/brynary/webrat"
  s.summary      = "Webrat. Ruby Acceptance Testing for Web applications"
  s.bindir       = "bin"
  s.description  = s.summary
  s.require_path = "lib"
  s.files        = %w(History.txt install.rb MIT-LICENSE.txt README.rdoc Rakefile) + Dir["lib/**/*"] + Dir["vendor/**/*"]

  # rdoc
  s.has_rdoc         = true
  s.extra_rdoc_files = %w(README.rdoc MIT-LICENSE.txt)

  # Dependencies
  s.add_dependency "nokogiri", ">= 1.0.6"
  
  s.rubyforge_project = "webrat"
end

Rake::GemPackageTask.new(spec) do |package|
  package.gem_spec = spec
end

desc 'Show information about the gem.'
task :debug_gem do
  puts spec.to_ruby
end

CLEAN.include ["pkg", "*.gem", "doc", "ri", "coverage"]

desc "Upload rdoc to brynary.com"
task :publish_rdoc => :docs do
  sh "scp -r doc/ brynary.com:/apps/uploads/webrat"
end

desc "Run API and Core specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc "Run all specs in spec directory with RCov"
Spec::Rake::SpecTask.new(:rcov) do |t|
  t.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.rcov = true
  t.rcov_opts = lambda do
    IO.readlines(File.dirname(__FILE__) + "/spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
  end
end

RCov::VerifyTask.new(:verify_rcov => :rcov) do |t|
  t.threshold = 96.2 # Make sure you have rcov 0.7 or higher!
end

desc 'Install the package as a gem.'
task :install_gem => [:clean, :package] do
  gem = Dir['pkg/*.gem'].first
  sh "sudo gem install --local #{gem}"
end

desc "Delete generated RDoc"
task :clobber_docs do
  FileUtils.rm_rf("doc")
end

desc "Generate RDoc"
task :docs => :clobber_docs do
  system "hanna --title 'Webrat #{Webrat::VERSION} API Documentation'"
end

desc "Run specs using jruby"
task "spec:jruby" do
  system "jruby -S rake spec"
end

desc "Run each spec in isolation to test for dependency issues"
task :spec_deps do
  Dir["spec/**/*_spec.rb"].each do |test|
    if !system("spec #{test} &> /dev/null")
      puts "Dependency Issues: #{test}"
    end
  end
end

task :default => :spec

task :precommit => ["spec", "spec:jruby"]