require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe "clicks_link" do
  before do
    @session = Webrat::TestSession.new
  end

  it "should use get by default" do
    @session.response_body = <<-EOS
      <a href="/page">Link text</a>
    EOS
    @session.expects(:get).with("/page", {})
    @session.clicks_link "Link text"
  end

  it "should click get links" do
    @session.response_body = <<-EOS
      <a href="/page">Link text</a>
    EOS
    @session.expects(:get).with("/page", {})
    @session.clicks_get_link "Link text"
  end
  
  it "should click delete links" do
    @session.response_body = <<-EOS
      <a href="/page">Link text</a>
    EOS
    @session.expects(:delete).with("/page", {})
    @session.clicks_delete_link "Link text"
  end
  
  it "should click post links" do
    @session.response_body = <<-EOS
      <a href="/page">Link text</a>
    EOS
    @session.expects(:post).with("/page", {})
    @session.clicks_post_link "Link text"
  end
  
  it "should click put links" do
    @session.response_body = <<-EOS
      <a href="/page">Link text</a>
    EOS
    @session.expects(:put).with("/page", {})
    @session.clicks_put_link "Link text"
  end
  
  it "should click rails javascript links with authenticity tokens" do
    @session.response_body = <<-EOS
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
    EOS
    @session.expects(:post).with("/posts", "authenticity_token" => "aa79cb354597a60a3786e7e291ed4f74d77d3a62")
    @session.clicks_link "Posts"
  end
  
  it "should click rails javascript delete links" do
    @session.response_body = <<-EOS
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
    EOS
    @session.expects(:delete).with("/posts/1", {})
    @session.clicks_link "Delete"
  end
  
  it "should click rails javascript post links" do
    @session.response_body = <<-EOS
      <a href="/posts" onclick="var f = document.createElement('form');
        f.style.display = 'none';
        this.parentNode.appendChild(f);
        f.method = 'POST';
        f.action = this.href;
        f.submit();
        return false;">Posts</a>
    EOS
    @session.expects(:post).with("/posts", {})
    @session.clicks_link "Posts"
  end
  
  it "should click rails javascript post links without javascript" do
    @session.response_body = <<-EOS
      <a href="/posts" onclick="var f = document.createElement('form');
        f.style.display = 'none';
        this.parentNode.appendChild(f);
        f.method = 'POST';
        f.action = this.href;
        f.submit();
        return false;">Posts</a>
    EOS
    @session.expects(:get).with("/posts", {})
    @session.clicks_link "Posts", :javascript => false
  end
  
  it "should click rails javascript put links" do
    @session.response_body = <<-EOS
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
    EOS
    @session.expects(:put).with("/posts", {})
    @session.clicks_link "Put"
  end
  
  it "should assert valid response" do
    @session.response_body = <<-EOS
      <a href="/page">Link text</a>
    EOS
    @session.response_code = 404
    lambda { @session.clicks_link "Link text" }.should raise_error
  end
  
  it "should not be case sensitive" do
    @session.response_body = <<-EOS
      <a href="/page">Link text</a>
    EOS
    @session.expects(:get).with("/page", {})
    @session.clicks_link "LINK TEXT"
  end
  
  it "should match link substrings" do
    @session.response_body = <<-EOS
      <a href="/page">This is some cool link text, isn't it?</a>
    EOS
    @session.expects(:get).with("/page", {})
    @session.clicks_link "Link text"
  end
  
  it "should work with elements in the link" do
    @session.response_body = <<-EOS
      <a href="/page"><span>Link text</span></a>
    EOS
    @session.expects(:get).with("/page", {})
    @session.clicks_link "Link text"
  end
  
  it "should match the first matching link" do
    @session.response_body = <<-EOS
      <a href="/page1">Link text</a>
      <a href="/page2">Link text</a>
    EOS
    @session.expects(:get).with("/page1", {})
    @session.clicks_link "Link text"
  end
  
  it "should choose the shortest link text match" do
    @session.response_body = <<-EOS
    <a href="/page1">Linkerama</a>
    <a href="/page2">Link</a>
    EOS
    
    @session.expects(:get).with("/page2", {})
    @session.clicks_link "Link"
  end
  
  it "should click link within a selector" do
    @session.response_body = <<-EOS
    <a href="/page1">Link</a>
    <div id="container">
      <a href="/page2">Link</a>
    </div>
    EOS
    
    @session.expects(:get).with("/page2", {})
    @session.clicks_link_within "#container", "Link"
  end

  it "should not make request when link is local anchor" do
    @session.response_body = <<-EOS
      <a href="#section-1">Jump to Section 1</a>
    EOS
    # Don't know why @session.expects(:get).never doesn't work here
    @session.expects(:send).with('get_via_redirect', '#section-1', {}).never
    @session.clicks_link "Jump to Section 1"
  end

  it "should follow relative links" do
    @session.current_page.stubs(:url).returns("/page")
    @session.response_body = <<-EOS
      <a href="sub">Jump to sub page</a>
    EOS
    @session.expects(:get).with("/page/sub", {})
    @session.clicks_link "Jump to sub page"
  end
  
  it "should follow fully qualified local links" do
    @session.response_body = <<-EOS
      <a href="http://www.example.com/page/sub">Jump to sub page</a>
    EOS
    @session.expects(:get).with("/page/sub", {})
    @session.clicks_link "Jump to sub page"
  end

  it "should follow query parameters" do
    @session.current_page.stubs(:url).returns("/page")
    @session.response_body = <<-EOS
      <a href="?foo=bar">Jump to foo bar</a>
    EOS
    @session.expects(:get).with("/page?foo=bar", {})
    @session.clicks_link "Jump to foo bar"
  end
end
