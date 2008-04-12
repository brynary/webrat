require File.dirname(__FILE__) + "/helper"

class ClicksLinkTest < Test::Unit::TestCase
  def setup
    @session = ActionController::Integration::Session.new
    @session.stubs(:assert_response)
    @session.stubs(:get_via_redirect)
    @session.stubs(:response).returns(@response=mock)
  end

  def test_should_use_get_by_default
    @response.stubs(:body).returns(<<-EOS)
      <a href="/page">Link text</a>
    EOS
    @session.expects(:get_via_redirect).with("/page", {})
    @session.clicks_link "Link text"
  end

  def test_should_click_get_links
    @response.stubs(:body).returns(<<-EOS)
      <a href="/page">Link text</a>
    EOS
    @session.expects(:get_via_redirect).with("/page", {})
    @session.clicks_get_link "Link text"
  end
  
  def test_should_click_delete_links
    @response.stubs(:body).returns(<<-EOS)
      <a href="/page">Link text</a>
    EOS
    @session.expects(:delete_via_redirect).with("/page", {})
    @session.clicks_delete_link "Link text"
  end
  
  def test_should_click_post_links
    @response.stubs(:body).returns(<<-EOS)
      <a href="/page">Link text</a>
    EOS
    @session.expects(:post_via_redirect).with("/page", {})
    @session.clicks_post_link "Link text"
  end
  
  def test_should_click_put_links
    @response.stubs(:body).returns(<<-EOS)
      <a href="/page">Link text</a>
    EOS
    @session.expects(:put_via_redirect).with("/page", {})
    @session.clicks_put_link "Link text"
  end
  
  def test_should_click_rails_javascript_links_with_authenticity_tokens
    @response.stubs(:body).returns(<<-EOS)
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
    @session.expects(:post_via_redirect).with("/posts", "authenticity_token" => "aa79cb354597a60a3786e7e291ed4f74d77d3a62")
    @session.clicks_link "Posts"
  end
  
  def test_should_click_rails_javascript_delete_links
    @response.stubs(:body).returns(<<-EOS)
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
    @session.expects(:delete_via_redirect).with("/posts/1", {})
    @session.clicks_link "Delete"
  end
  
  def test_should_click_rails_javascript_post_links
    @response.stubs(:body).returns(<<-EOS)
      <a href="/posts" onclick="var f = document.createElement('form');
        f.style.display = 'none';
        this.parentNode.appendChild(f);
        f.method = 'POST';
        f.action = this.href;
        f.submit();
        return false;">Posts</a>
    EOS
    @session.expects(:post_via_redirect).with("/posts", {})
    @session.clicks_link "Posts"
  end
  
  def test_should_click_rails_javascript_put_links
    @response.stubs(:body).returns(<<-EOS)
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
    @session.expects(:put_via_redirect).with("/posts", {})
    @session.clicks_link "Put"
  end
  
  def test_should_assert_valid_response
    @response.stubs(:body).returns(<<-EOS)
      <a href="/page">Link text</a>
    EOS
    @session.expects(:assert_response).with(:success)
    @session.clicks_link "Link text"
  end
  
  def test_should_not_be_case_sensitive
    @response.stubs(:body).returns(<<-EOS)
      <a href="/page">Link text</a>
    EOS
    @session.expects(:get_via_redirect).with("/page", {})
    @session.clicks_link "LINK TEXT"
  end
  
  def test_should_match_link_substrings
    @response.stubs(:body).returns(<<-EOS)
      <a href="/page">This is some cool link text, isn't it?</a>
    EOS
    @session.expects(:get_via_redirect).with("/page", {})
    @session.clicks_link "Link text"
  end
  
  def test_should_work_with_elements_in_the_link
    @response.stubs(:body).returns(<<-EOS)
      <a href="/page"><span>Link text</span></a>
    EOS
    @session.expects(:get_via_redirect).with("/page", {})
    @session.clicks_link "Link text"
  end
  
  def test_should_match_the_first_matching_link
    @response.stubs(:body).returns(<<-EOS)
      <a href="/page1">Link text</a>
      <a href="/page2">Link text</a>
    EOS
    @session.expects(:get_via_redirect).with("/page1", {})
    @session.clicks_link "Link text"
  end
  
  def test_should_choose_the_shortest_link_text_match
    @response.stubs(:body).returns(<<-EOS)
    <a href="/page1">Linkerama</a>
    <a href="/page2">Link</a>
    EOS
    
    @session.expects(:get_via_redirect).with("/page2", {})
    @session.clicks_link "Link"
  end
  
  def test_should_click_link_within_a_selector
    @response.stubs(:body).returns(<<-EOS)
    <a href="/page1">Link</a>
    <div id="container">
      <a href="/page2">Link</a>
    </div>
    EOS
    
    @session.expects(:get_via_redirect).with("/page2", {})
    @session.clicks_link_within "#container", "Link"
  end

  def test_should_not_make_request_when_link_is_local_anchor
    @response.stubs(:body).returns(<<-EOS)
      <a href="#section-1">Jump to Section 1</a>
    EOS
    # Don't know why @session.expects(:get_via_redirect).never doesn't work here
    @session.expects(:send).with('get_via_redirect', '#section-1', {}).never
    @session.clicks_link "Jump to Section 1"
  end
end
