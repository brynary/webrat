# def clicks_link_with_method(link_text, http_method) # :nodoc:
#   link = all_links.detect { |el| el.innerHTML =~ /#{link_text}/i }
#   flunk("No link with text #{link_text.inspect} was found") if link.nil?
#   request_page(http_method, link.attributes["href"])
# end
# 
# def find_shortest_matching_link(links, link_text)
#   candidates = links.select { |el| el.innerHTML =~ /#{link_text}/i }
#   candidates.sort_by { |el| el.innerText.strip.size }.first
# end
# 
# def clicks_one_link_of(links, link_text)
#   link = find_shortest_matching_link(links, link_text)
# 
#   flunk("No link with text #{link_text.inspect} was found") if link.nil?
# 
#   onclick = link.attributes["onclick"]
#   href    = link.attributes["href"]
# 
#   http_method = http_method_from_js(onclick)
#   authenticity_token = authenticity_token_value(onclick)
# 
#   request_page(http_method, href, authenticity_token.blank? ? {} : {"authenticity_token" => authenticity_token}) unless href =~ /^#/ && http_method == :get
# end
# 
# def all_links # :nodoc:
#   (dom / "a[@href]")
# end
# 
# def links_within(selector) # :nodoc:
#   (dom / selector / "a[@href]")
# end