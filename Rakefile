require 'rubygems'
require "rake/gempackagetask"
require 'rake/rdoctask'
require "rake/clean"
require 'spec'
require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'
require './lib/webrat.rb'

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
  s.files        = %w(History.txt init.rb install.rb MIT-LICENSE.txt README.txt Rakefile TODO.txt) + Dir["lib/**/*"]

  # rdoc
  s.has_rdoc         = true
  s.extra_rdoc_files = %w(README.txt MIT-LICENSE.txt)

  # Dependencies
  s.add_dependency "nokogiri", ">= 1.0.3"
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

task :default do
  Rake::Task["verify_rcov"].invoke
end

desc 'Install the package as a gem.'
task :install_gem => [:clean, :package] do
  gem = Dir['pkg/*.gem'].first
  sh "sudo gem install --local #{gem}"
end

Rake::RDocTask.new(:docs) do |rd|
  rd.main = "README.txt"
  rd.rdoc_dir = 'doc'
  files = spec.files.grep(/^(lib|bin|ext)|txt$/)
  files -= ["TODO.txt"]
  files -= files.grep(/\.js$/)
  rd.rdoc_files = files.uniq
  title = "webrat-#{Webrat::VERSION} Documentation"
  rd.options << "-t #{title}"
end