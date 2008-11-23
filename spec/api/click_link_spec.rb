require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "click_link" do
  it "should click links with ampertands" do
    with_html <<-HTML
      <a href="/page">Save &amp; go back</a>
    HTML
    webrat_session.should_receive(:get).with("/page", {})
    click_link "Save & go back"
  end
  
  it "should use get by default" do
    with_html <<-HTML
      <a href="/page">Link text</a>
    HTML
    webrat_session.should_receive(:get).with("/page", {})
    click_link "Link text"
  end

  it "should click get links" do
    with_html <<-HTML
      <a href="/page">Link text</a>
    HTML
    webrat_session.should_receive(:get).with("/page", {})
    click_link "Link text", :method => :get
  end
  
  it "should click link on substring" do
    with_html <<-HTML
      <a href="/page">Link text</a>
    HTML
    webrat_session.should_receive(:get).with("/page", {})
    clicks_link "ink tex", :method => :get
  end
  
  it "should click delete links" do
    with_html <<-HTML
      <a href="/page">Link text</a>
    HTML
    webrat_session.should_receive(:delete).with("/page", {})
    click_link "Link text", :method => :delete
  end
  
  
  it "should click post links" do
    with_html <<-HTML
      <a href="/page">Link text</a>
    HTML
    webrat_session.should_receive(:post).with("/page", {})
    click_link "Link text", :method => :post
  end
  
  it "should click put links" do
    with_html <<-HTML
      <a href="/page">Link text</a>
    HTML
    webrat_session.should_receive(:put).with("/page", {})
    click_link "Link text", :method => :put
  end
  
  it "should click links by regexp" do
    with_html <<-HTML
      <a href="/page">Link text</a>
    HTML
    webrat_session.should_receive(:get).with("/page", {})
    click_link /link [a-z]/i
  end
  
  it "should click links by id" do 
    with_html <<-HTML
      <a id="link_text_link" href="/page">Link text</a>
    HTML
    webrat_session.should_receive(:get).with("/page", {})
    clicks_link "link_text_link"
  end
  
  it "should click links by id regexp" do 
    with_html <<-HTML
      <a id="link_text_link" href="/page">Link text</a>
    HTML
    webrat_session.should_receive(:get).with("/page", {})
    clicks_link /_text_/
  end
  
  it "should click rails javascript links with authenticity tokens" do
    with_html <<-HTML
      <a href="/posts" onclick="var f = document.createElement('form');
        f.style.display = 'none';
        this.parentNode.appendChild(f);
        f.method = 'POST';
        f.action = this.href;
        var s = document.createElement('input');
        s.setAttribute('type', 'hidden');
        s.setAttribute('name', 'authenticity_token');
        s.setAttribute('value', 'aa79cb354597a60a3786e7e291ed4f74d77d3a62');
        f.appendChild(s);
        f.submit();
        return false;">Posts</a>
    HTML
    webrat_session.should_receive(:post).with("/posts", "authenticity_token" => "aa79cb354597a60a3786e7e291ed4f74d77d3a62")
    click_link "Posts"
  end
  
  it "should click rails javascript delete links" do
    with_html <<-HTML
      <a href="/posts/1" onclick="var f = document.createElement('form');
        f.style.display = 'none';
        this.parentNode.appendChild(f);
        f.method = 'POST';
        f.action = this.href;
        var m = document.createElement('input');
        m.setAttribute('type', 'hidden');
        m.setAttribute('name', '_method');
        m.setAttribute('value', 'delete');
        f.appendChild(m);
        f.submit();
        return false;">Delete</a>
    HTML
    webrat_session.should_receive(:delete).with("/posts/1", {})
    click_link "Delete"
  end
  
  it "should click rails javascript post links" do
    with_html <<-HTML
      <a href="/posts" onclick="var f = document.createElement('form');
        f.style.display = 'none';
        this.parentNode.appendChild(f);
        f.method = 'POST';
        f.action = this.href;
        f.submit();
        return false;">Posts</a>
    HTML
    webrat_session.should_receive(:post).with("/posts", {})
    click_link "Posts"
  end
  
  it "should click rails javascript post links without javascript" do
    with_html <<-HTML
      <a href="/posts" onclick="var f = document.createElement('form');
        f.style.display = 'none';
        this.parentNode.appendChild(f);
        f.method = 'POST';
        f.action = this.href;
        f.submit();
        return false;">Posts</a>
    HTML
    webrat_session.should_receive(:get).with("/posts", {})
    click_link "Posts", :javascript => false
  end
  
  it "should click rails javascript put links" do
    with_html <<-HTML
      <a href="/posts" onclick="var f = document.createElement('form');
        f.style.display = 'none';
        this.parentNode.appendChild(f);
        f.method = 'POST';
        f.action = this.href;
        var m = document.createElement('input');
        m.setAttribute('type', 'hidden');
        m.setAttribute('name', '_method');
        m.setAttribute('value', 'put');
        f.appendChild(m);
        f.submit();
        return false;">Put</a></h2>
    HTML
    webrat_session.should_receive(:put).with("/posts", {})
    click_link "Put"
  end
  
  it "should fail if the javascript link doesn't have a value for the _method input" do
    with_html <<-HTML
      <a href="/posts/1" onclick="var f = document.createElement('form');
        f.style.display = 'none';
        this.parentNode.appendChild(f);
        f.method = 'POST';
        f.action = this.href;
        var m = document.createElement('input');
        m.setAttribute('type', 'hidden');
        m.setAttribute('name', '_method');
        f.appendChild(m);
        f.submit();
        return false;">Link</a>
    HTML
    
    lambda {
      click_link "Link"
    }.should raise_error
  end
  
  it "should assert valid response" do
    with_html <<-HTML
      <a href="/page">Link text</a>
    HTML
    webrat_session.response_code = 501
    lambda { click_link "Link text" }.should raise_error(Webrat::PageLoadError)
  end
  
  [200, 300, 400, 499].each do |status|
    it "should consider the #{status} status code as success" do
      with_html <<-HTML
        <a href="/page">Link text</a>
      HTML
      webrat_session.response_code = status
      lambda { click_link "Link text" }.should_not raise_error
    end
  end
  
  it "should fail is the link doesn't exist" do
    with_html <<-HTML
      <a href="/page">Link text</a>
    HTML
    
    lambda {
      click_link "Missing link"
    }.should raise_error
  end
  
  it "should not be case sensitive" do
    with_html <<-HTML
      <a href="/page">Link text</a>
    HTML
    webrat_session.should_receive(:get).with("/page", {})
    click_link "LINK TEXT"
  end
  
  it "should match link substrings" do
    with_html <<-HTML
      <a href="/page">This is some cool link text, isn't it?</a>
    HTML
    webrat_session.should_receive(:get).with("/page", {})
    click_link "Link text"
  end
  
  it "should work with elements in the link" do
    with_html <<-HTML
      <a href="/page"><span>Link text</span></a>
    HTML
    webrat_session.should_receive(:get).with("/page", {})
    click_link "Link text"
  end
  
  it "should match the first matching link" do
    with_html <<-HTML
      <a href="/page1">Link text</a>
      <a href="/page2">Link text</a>
    HTML
    webrat_session.should_receive(:get).with("/page1", {})
    click_link "Link text"
  end
  
  it "should choose the shortest link text match" do
    with_html <<-HTML
    <html>
      <a href="/page1">Linkerama</a>
      <a href="/page2">Link</a>
    </html>
    HTML
    
    webrat_session.should_receive(:get).with("/page2", {})
    click_link "Link"
  end
  
  it "should treat non-breaking spaces as spaces" do
    with_html <<-HTML
    <html>
      <a href="/page1">This&nbsp;is&nbsp;a&nbsp;link</a>
    </html>
    HTML
    
    webrat_session.should_receive(:get).with("/page1", {})
    click_link "This is a link"
  end
  
  it "should not match on non-text contents" do
    pending "needs fix" do
      with_html <<-HTML
      <a href="/page1"><span class="location">My house</span></a>
      <a href="/page2">Location</a>
      HTML
    
      webrat_session.should_receive(:get).with("/page2", {})
      click_link "Location"
    end
  end
  
  it "should click link within a selector" do
    with_html <<-HTML
    <html>
    <a href="/page1">Link</a>
    <div id="container">
      <a href="/page2">Link</a>
    </div>
    </html>
    HTML
    
    webrat_session.should_receive(:get).with("/page2", {})
    click_link_within "#container", "Link"
  end

  it "should not make request when link is local anchor" do
    with_html <<-HTML
      <a href="#section-1">Jump to Section 1</a>
    HTML
    # Don't know why webrat_session.should_receive(:get).never doesn't work here
    webrat_session.should_receive(:send).with('get_via_redirect', '#section-1', {}).never
    click_link "Jump to Section 1"
  end

  it "should follow relative links" do
    webrat_session.stub!(:current_url => "/page")
    with_html <<-HTML
      <a href="sub">Jump to sub page</a>
    HTML
    webrat_session.should_receive(:get).with("/page/sub", {})
    click_link "Jump to sub page"
  end
  
  it "should follow fully qualified local links" do
    webrat_session.stub!(:current_url => "/page")
    with_html <<-HTML
      <a href="http://subdomain.example.com/page/sub">Jump to sub page</a>
    HTML
    webrat_session.should_receive(:get).with("http://subdomain.example.com/page/sub", {})
    click_link "Jump to sub page"
  end
  
  it "should follow fully qualified local links to example.com" do
    with_html <<-HTML
      <a href="http://www.example.com/page/sub">Jump to sub page</a>
    HTML
    webrat_session.should_receive(:get).with("http://www.example.com/page/sub", {})
    click_link "Jump to sub page"
  end

  it "should follow query parameters" do
    webrat_session.stub!(:current_url => "/page")
    with_html <<-HTML
      <a href="?foo=bar">Jump to foo bar</a>
    HTML
    webrat_session.should_receive(:get).with("/page?foo=bar", {})
    click_link "Jump to foo bar"
  end
end
