module RubyHtmlUnit
  
  class AlertHandler
    def handleAlert(html_unit_page, alert_message)
      alert_messages << alert_message
    end
    
    def alert_messages
      @alert_messages ||= []
    end
  end
  
end