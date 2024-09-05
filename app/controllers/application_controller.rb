class ApplicationController < ActionController::Base
  include ActionController::RequestForgeryProtection
  # tokenがセットされているか確認
  protect_from_forgery with: :exception

  def set_csrf_token_header
    response.set_header('X-CSRF-Token', form_authenticity_toke)
  end

  # APIリクエスト用にCSRF検証を設定
  protect_from_forgery with: :null_session, if: -> { request.format.json? }
end