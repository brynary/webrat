require 'rubygems'
require 'hoe'
require './lib/webrat.rb'

Hoe.new('webrat', Webrat::VERSION) do |p|
  p.rubyforge_name = 'webrat'
  p.author = ['Bryan Helmkamp', 'Seth Fitzsimmons']
  p.email = 'bryan@brynary.com'
  p.summary = 'Ruby Acceptance Testing for Web applications'
  
  p.description = p.paragraphs_of('README.txt', 2..5).join("\n\n")
  p.url = p.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1]
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  
  p.test_globs = ['test/**/*_test.rb']
end

desc "Upload rdoc to brynary.com"
task :publish_rdoc => :docs do
  sh "scp -r doc/ brynary.com:/apps/uploads/webrat"
end 

# desc 'Generate RDoc documentation for the Webrat plugin.'
# Rake::RDocTask.new(:rdoc) do |rdoc|
#   rdoc.options << '--line-numbers' << '--inline-source'
#   rdoc.rdoc_files.include('README')
#   rdoc.rdoc_files.include('lib/**/*.rb')
# end
