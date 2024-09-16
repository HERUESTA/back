class TwitchController < ApplicationController
  require 'net/http'
  require 'uri'
  require 'json'

  #root
  def index
    redirect_to ENV['NEXT_PUBLIC_REDIRECT_AFTER_LOGIN_URL']  # Next.jsが動作しているURLにリダイレクト
  end

  # ゲーム名検索
def clips_by_game
  game_name = params[:game_name]

  # ゲーム名からゲームIDを取得
  game_id = get_game_id(game_name)

  # デバッグ用ログ出力
  Rails.logger.info("Game name: #{game_name}, Game ID: #{game_id}")

  if game_id.nil?
    render json: { error: "ゲームが見つかりませんでした" }, status: :not_found
    return
  end

  uri = URI("https://api.twitch.tv/helix/clips?game_id=#{game_id}&first=100")
  response = send_twitch_request(uri)

  if response.is_a?(Net::HTTPSuccess)
    clips = JSON.parse(response.body)['data']
    japanese_clips = clips.select { |clip| clip['language'] == 'ja' }
    render json: japanese_clips
  else
    render json: { error: response.message, body: response.body, status_code: response.code }, status: response.code
  end
end

  private

  def send_twitch_request(uri)
    Rails.logger.debug "Requesting URI: #{uri}"
    request = Net::HTTP::Get.new(uri)
    request['Client-ID'] = ENV['TWITCH_CLIENT_ID']
    request['Authorization'] = "Bearer #{ENV['TWITCH_ACCESS_TOKEN']}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    response
  end

  def get_game_id(game_name)
    uri = URI("https://api.twitch.tv/helix/games?name=#{URI.encode_www_form_component(game_name)}")
    response = send_twitch_request(uri)

    if response.is_a?(Net::HTTPSuccess)
      game_data = JSON.parse(response.body)
      game_data['data'].first['id'] if game_data['data'].any?
    else
      nil
    end
  end
end