class ApplicationController < ActionController::Base
  include ActionController::RequestForgeryProtection
  # tokenがセットされているか確認
  protect_from_forgery with: :exception

  def set_csrf_token_header
    response.set_header('X-CSRF-Token', form_authenticity_toke)
  end

  # APIリクエスト用にCSRF検証を設定
  protect_from_forgery with: :null_session, if: -> { request.format.json? }

  # Faraday接続設定を追加
  def twitch_connection
    @twitch_connection ||= Faraday.new(url: 'https://api.twitch.tv/helix') do |conn|
      conn.headers['Client-ID'] = ENV['TWITCH_CLIENT_ID']
      conn.headers['Authorization'] = "Bearer #{ENV['TWITCH_ACCESS_TOKEN']}"
      conn.adapter Faraday.default_adapter 
    end
  end
end   