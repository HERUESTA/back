class ApplicationController < ActionController::Base
  include ActionController::RequestForgeryProtection
  before_action :debug_cookies

  # tokenがセットされているか確認
  protect_from_forgery with: :exception

  def debug_cookies
    Rails.logger.debug "Current cookies: #{cookies.to_hash.inspect}"
    Rails.logger.debug "Current session: #{session.to_hash.inspect}"
  end
  
end