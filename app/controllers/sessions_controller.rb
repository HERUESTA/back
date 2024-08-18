class SessionsController < ApplicationController

  def new
    # Twitchの認証を開始するために、/auth/twitch にリダイレクトします
    
  end

  def create
    auth = request.env['omniauth.auth']
    if auth.nil?
      Rails.logger.error "OmniAuth auth hash is nil"
      redirect_to root_path, alert: "Authentication failed"
      return
    end

    user = User.find_or_create_by(uid: auth['uid']) do |u|
      u.name = auth['info']['name']
      u.token = auth['credentials']['token']
    end
    session[:user_id] = user.id
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    head :no_content
  end
end