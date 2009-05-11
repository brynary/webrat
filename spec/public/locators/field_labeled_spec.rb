require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")


describe "field_labeled" do
  class << self
    def using_this_html html
      before(:each) do
        with_html(html)
      end
    end

    def field_labeled(label)
      @label = label
      yield
    end

    def should_return_a type, opts
      it "should return a textfield" do
        field_labeled(opts[:for]).should be_an_instance_of(type)
      end
    end

    def with_an_id_of id, opts
      it "should return an element with the correct id" do
        field_labeled(opts[:for]).should match_id(id)
      end
    end

    def should_raise_error_matching regexp, opts
      it "should raise with wrong label" do
        lambda {
          field_labeled(opts[:for])
        }.should raise_error(regexp)
      end
    end
  end

  def match_id(id)
    simple_matcher "element with id #{id.inspect}" do |element, matcher|
      if id.is_a?(Regexp)
        element.id =~ id
      else
        element.id == id.to_s
      end
    end
  end

  describe "finding a text field" do
    using_this_html <<-HTML
      <html>
      <form>
      <label for="element_42">The Label</label>
      <input type="text" id="element_42">
      </form>
      </html>
    HTML

    should_return_a Webrat::TextField, :for => "The Label"
    with_an_id_of  "element_42",       :for => "The Label"
    should_raise_error_matching /Could not find .* "Other Label"/, :for => "Other Label"
  end

  describe "finding a hidden field" do
    using_this_html <<-HTML
      <html>
      <form>
      <label for="element_42">The Label</label>
      <input type="hidden" id="element_42">
      </form>
      </html>
    HTML

    should_return_a Webrat::HiddenField, :for => "The Label"
    with_an_id_of  "element_42",         :for => "The Label"
    should_raise_error_matching /Could not find .* "Other Label"/, :for => "Other Label"
  end

  describe "finding a checkbox" do
    using_this_html <<-HTML
      <html>
      <form>
      <label for="element_42">The Label</label>
      <input type="checkbox" id="element_42">
      </form>
      </html>
    HTML

    should_return_a Webrat::CheckboxField, :for => "The Label"
    with_an_id_of  "element_42",           :for => "The Label"
    should_raise_error_matching /Could not find .* "Other Label"/, :for => "Other Label"
  end

  describe "finding a radio button" do
    using_this_html <<-HTML
      <html>
      <form>
      <label for="element_42">The Label</label>
      <input type="radio" id="element_42">
      </form>
      </html>
    HTML

    should_return_a Webrat::RadioField, :for => "The Label"
    with_an_id_of  "element_42",        :for => "The Label"
    should_raise_error_matching /Could not find .* "Other Label"/, :for => "Other Label"
  end


  describe "finding a text area" do
    using_this_html <<-HTML
      <html>
      <form>
      <label for="element_42">The Label</label>
      <textarea id="element_42"></textarea>
      </form>
      </html>
    HTML

    should_return_a Webrat::TextareaField, :for => "The Label"
    with_an_id_of  "element_42",           :for => "The Label"
    should_raise_error_matching /Could not find .* "Other Label"/, :for => "Other Label"
  end

  describe "finding a field with it's label containing newlines" do
    using_this_html <<-HTML
      <html>
        <form>
          <label for="element_42">
            A label with
            <a>a link on it's own line</a>
          </label>
          <input type="text" id="element_42">
        </form>
      </html>
    HTML

    should_return_a Webrat::TextField, :for => "A label with a link on it's own line"
    with_an_id_of  "element_42",       :for => "A label with a link on it's own line"
    should_raise_error_matching /Could not find .* "Other Label"/, :for => "Other Label"
  end

  describe "finding a field when labels without fields also match" do
    using_this_html <<-HTML
      <html>
        <label>The Label</label>
        <form>
          <label for="element_42">The Label</label>
          <input type="text" id="element_42">
        </form>
      </html>
    HTML

    should_return_a Webrat::TextField, :for => "The Label"
    with_an_id_of   "element_42",      :for => "The Label"
  end

  describe "finding a field whose label ends with an non word character" do
    using_this_html <<-HTML
      <html>
      <form>
      <label for="element_42">License #</label>
      <input type="text" id="element_42">
      </form>
      </html>
    HTML

    should_return_a Webrat::TextField, :for => "License #"
    with_an_id_of  "element_42",       :for => "License #"
    should_raise_error_matching /Could not find .* "Other License #"/, :for => "Other License #"
  end

end
