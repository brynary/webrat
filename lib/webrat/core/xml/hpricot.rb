module Webrat

  def self.hpricot_document(stringlike)
    return stringlike.dom if stringlike.respond_to?(:dom)

    if Hpricot::Doc === stringlike
      stringlike
    elsif Hpricot::Elements === stringlike
      stringlike
    elsif StringIO === stringlike
      Hpricot(stringlike.string)
    elsif stringlike.respond_to?(:body)
      Hpricot(stringlike.body.to_s)
    else
      Hpricot(stringlike.to_s)
    end
  end

end
