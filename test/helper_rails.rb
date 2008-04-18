require "active_support"
silence_warnings do
  require "action_controller"
  require "action_controller/integration"
end

class ActionController::Integration::Session
  def flunk(message)
    raise message
  end
end