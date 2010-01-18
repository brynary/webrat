module GemHelpers

  def generate_gemspec
    $LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), "lib")))
    require "webrat"

    Gem::Specification.new do |s|
      s.name      = "webrat"
      s.version   = Webrat::VERSION
      s.author    = "Bryan Helmkamp"
      s.email     = "bryan@brynary.com"
      s.homepage  = "http://github.com/brynary/webrat"
      s.summary   = "Ruby Acceptance Testing for Web applications"
      s.description  = <<-EOS.strip
Webrat lets you quickly write expressive and robust acceptance tests
for a Ruby web application. It supports simulating a browser inside
a Ruby process to avoid the performance hit and browser dependency of
Selenium or Watir, but the same API can also be used to drive real
Selenium tests when necessary (eg. for testing AJAX interactions).
Most Ruby web frameworks and testing frameworks are supported.
      EOS
      s.rubyforge_project = "webrat"

      require "git"
      repo = Git.open(".")

      s.files      = normalize_files(repo.ls_files.keys - repo.lib.ignored_files)
      s.test_files = normalize_files(Dir['spec/**/*.rb'] - repo.lib.ignored_files)

      s.has_rdoc = true
      s.extra_rdoc_files = %w[README.rdoc MIT-LICENSE.txt History.txt]

      s.add_dependency "nokogiri", ">= 1.2.0"
      s.add_dependency "rack", ">= 1.0"
      s.add_dependency "rack-test", ">= 0.5.3"
    end
  end

  def normalize_files(array)
    # only keep files, no directories, and sort
    array.select do |path|
      File.file?(path)
    end.sort
  end

  # Adds extra space when outputting an array. This helps create better version
  # control diffs, because otherwise it is all on the same line.
  def prettyify_array(gemspec_ruby, array_name)
    gemspec_ruby.gsub(/s\.#{array_name.to_s} = \[.+?\]/) do |match|
      leadin, files = match[0..-2].split("[")
      leadin + "[\n    #{files.split(",").join(",\n   ")}\n  ]"
    end
  end

  def read_gemspec
    @read_gemspec ||= eval(File.read("webrat.gemspec"))
  end

  def sh(command)
    puts command
    system command
  end
end

class Default < Thor
  include GemHelpers

  desc "gemspec", "Regenerate webrat.gemspec"
  def gemspec
    File.open("webrat.gemspec", "w") do |file|
      gemspec_ruby = generate_gemspec.to_ruby
      gemspec_ruby = prettyify_array(gemspec_ruby, :files)
      gemspec_ruby = prettyify_array(gemspec_ruby, :test_files)
      gemspec_ruby = prettyify_array(gemspec_ruby, :extra_rdoc_files)

      file.write gemspec_ruby
    end

    puts "Wrote gemspec to webrat.gemspec"
    read_gemspec.validate
  end

  desc "build", "Build a webrat gem"
  def build
    sh "gem build webrat.gemspec"
    FileUtils.mkdir_p "pkg"
    FileUtils.mv read_gemspec.file_name, "pkg"
  end

  desc "install", "Install the latest built gem"
  def install
    sh "gem install --local pkg/#{read_gemspec.file_name}"
  end

  desc "release", "Release the current branch to GitHub and Gemcutter"
  def release
    gemspec
    build
    Release.new.tag
    Release.new.gem
  end
end

class Release < Thor
  include GemHelpers

  desc "tag", "Tag the gem on the origin server"
  def tag
    release_tag = "v#{read_gemspec.version}"
    sh "git tag -a #{release_tag} -m 'Tagging #{release_tag}'"
    sh "git push origin #{release_tag}"
  end

  desc "gem", "Push the gem to Gemcutter"
  def gem
    sh "gem push pkg/#{read_gemspec.file_name}"
  end
end