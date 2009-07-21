class ApplicationController < ActionController::Base
  LacksWriteAccess = Class.new(RuntimeError)
  
  # Making sure everything in params is UTF-8 on Ruby 1.9
  if String.method_defined?(:force_encoding)
    before_filter {|c| c.send(:convert_to_utf_8, c.params) }
  end
  
  protect_from_forgery
  filter_parameter_logging :password
  
  private
  
  def current_user
    return @current_user if defined?(@current_user)
    user_session = UserSession.find
    @current_user = user_session && user_session.user
  end
  
  def logged_in?
    current_user.is_a?(User)
  end
  
  def admin?
    logged_in? && current_user.admin?
  end
  
  def write_access?
    Kii::CONFIG[:public_write] || logged_in?
  end
  
  def require_write_access
    raise LacksWriteAccess unless write_access?
  end
  
  def require_login
    redirect_to new_session_path unless logged_in?
  end
  
  def require_admin
    redirect_to new_session_path unless admin?
  end
  
  helper_method :current_user, :logged_in?, :admin?, :write_access?, :registration_enabled?
  
  def convert_to_utf_8(target)
    case target
    when String
      target.force_encoding("UTF-8")
    when Hash
      target.each {|k, v| convert_to_utf_8(v) }
    when Array
      target.each {|k, v| convert_to_utf_8(v) }
    end
  end
end
