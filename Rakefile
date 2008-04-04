require 'rubygems'
require 'hoe'
require './lib/webrat.rb'

Hoe.new('webrat', Webrat::VERSION) do |p|
  p.rubyforge_name = 'webrat'
  p.summary = 'Ruby Acceptance Testing for Web applications'
  
  p.developer "Bryan Helmkamp",   "bryan@brynary.com"
  p.developer "Seth Fitzsimmons", "seth@mojodna.net"
  
  # require "rubygems"; require "ruby-debug"; Debugger.start; debugger
  
  p.description = p.paragraphs_of('README.txt', 4..6).join("\n\n")
  p.url = p.paragraphs_of('README.txt', 1).first.split("\n").first.strip
  p.changes = p.paragraphs_of('History.txt', 0..3).join("\n\n")

  p.extra_deps << ["hpricot", ">= 0.6"]
  
  p.remote_rdoc_dir = '' # Release to root
  p.test_globs = ['test/**/*_test.rb']
end

desc "Upload rdoc to brynary.com"
task :publish_rdoc => :docs do
  sh "scp -r doc/ brynary.com:/apps/uploads/webrat"
end