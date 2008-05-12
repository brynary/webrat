require 'rubygems'
require 'hoe'
require 'spec'
require 'spec/rake/spectask'
require './lib/webrat.rb'

Hoe.new('webrat', Webrat::VERSION) do |p|
  p.rubyforge_name = 'webrat'
  p.summary = 'Ruby Acceptance Testing for Web applications'
  
  p.developer "Bryan Helmkamp",   "bryan@brynary.com"
  p.developer "Seth Fitzsimmons", "seth@mojodna.net"
  
  p.description = p.paragraphs_of('README.txt', 4..6).join("\n\n")
  p.url = p.paragraphs_of('README.txt', 1).first.split("\n").first.strip
  p.changes = p.paragraphs_of('History.txt', 0..3).join("\n\n")

  p.extra_deps << ["hpricot", ">= 0.6"]
  
  p.remote_rdoc_dir = '' # Release to root
end

desc "Upload rdoc to brynary.com"
task :publish_rdoc => :docs do
  sh "scp -r doc/ brynary.com:/apps/uploads/webrat"
end

Rake::TaskManager.class_eval do
  def remove_task(task_name)
    @tasks.delete(task_name.to_s)
  end
end
 
def remove_task(task_name)
  Rake.application.remove_task(task_name)
end

remove_task "test"
remove_task "test_deps"

desc "Run all specs in spec directory"
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

require 'spec/rake/verify_rcov'
RCov::VerifyTask.new(:verify_rcov => :rcov) do |t|
  t.threshold = 97.1 # Make sure you have rcov 0.7 or higher!
end

remove_task "default"
task :default do
  Rake::Task["verify_rcov"].invoke
end