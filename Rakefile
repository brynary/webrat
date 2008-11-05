require 'rubygems'
require 'spec'
require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'
require './lib/webrat.rb'

# Hoe.new('webrat', Webrat::VERSION) do |p|
#   p.rubyforge_name = 'webrat'
#   p.summary = 'Ruby Acceptance Testing for Web applications'
#   
#   p.developer "Bryan Helmkamp",   "bryan@brynary.com"
#   p.developer "Seth Fitzsimmons", "seth@mojodna.net"
#   
#   p.description = p.paragraphs_of('README.txt', 4..6).join("\n\n")
#   p.url = p.paragraphs_of('README.txt', 1).first.split("\n").first.strip
#   p.changes = p.paragraphs_of('History.txt', 0..3).join("\n\n")
# 
#   p.extra_deps << ["hpricot", ">= 0.6"]
#   
#   p.remote_rdoc_dir = '' # Release to root
# end

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