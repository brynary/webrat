module Webrat
  module SaveAndOpenPage
    # Saves the page out to Rails.root/tmp/ and opens it in the default
    # web browser if on OS X. Useful for debugging.
    #
    # Example:
    #   save_and_open_page
    def save_and_open_page
      return unless File.exist?(Webrat.configuration.saved_pages_dir)

      filename = "#{Webrat.configuration.saved_pages_dir}/webrat-#{Time.now.to_i}.html"

      File.open(filename, "w") do |f|
        f.write response_body
      end

      open_in_browser(filename)
    end

    def open_in_browser(path) # :nodoc
      require "launchy"
      Launchy::Browser.run(path)
    rescue LoadError
      warn "Sorry, you need to install launchy to open pages: `gem install launchy`"
    end

  end
end
