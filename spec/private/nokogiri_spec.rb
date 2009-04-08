require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

if defined?(Nokogiri::XML) && Webrat.configuration.parse_with_nokogiri?
  describe "Nokogiri Extension" do
    include Webrat::Matchers

    def fail
      raise_error(Spec::Expectations::ExpectationNotMetError)
    end

    before(:each) do
      @text_and_password = <<-HTML
        <div>
          <input type="text"/>
          <input type="password"/>
          <span type="text"/>
        </div>
      HTML

      @text_only = <<-HTML
        <div>
          <input type="text" disabled="disabled" />
        </div>
      HTML

      @password_only = <<-HTML
        <div>
          <input type="password"/>
        <div>
      HTML
    end

    describe ":text" do
      it "passes have_selector(:text) if a node with type=text exists" do
        @text_and_password.should have_selector(":text")
      end

      it "passes not have_selector(:text) if no node with text=text exists" do
        @password_only.should_not have_selector(":text")
      end

      it "fails have_selector(:text) if no node with type=text exists" do
        lambda { @password_only.should have_selector(":text") }.should fail
      end

      it "fails not have_selector(:text) if a node with type=text exists" do
        lambda { @text_only.should_not have_selector(":text") }.should fail
      end

      it "works together with other selectors" do
        @text_and_password.should have_selector("input:text[type*='te']")
      end
    end

    describe ":password" do
      it "passes have_selector(:password) if a node with type=password exists" do
        @text_and_password.should have_selector(":password")
      end

      it "passes not have_selector(:text) if no node with text=text exists" do
        @text_only.should_not have_selector(":password")
      end

      it "fails have_selector(:password) if no node with type=password exists" do
        lambda { @text_only.should have_selector(":password") }.should fail
      end

      it "fails not have_selector(:password) if a node with type=password exists" do
        lambda { @password_only.should_not have_selector(":password") }.should fail
      end

      it "works together with other selectors" do
        @text_and_password.should have_selector("input:password[type*='pa']")
      end
    end
  end
end
