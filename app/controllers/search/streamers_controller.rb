
# app/search/streamers_controller.rb
module Search
  class StreamersController < ApplicationController

    # 配信者名検索
    def show 
      streamer_name = params[:id]
      streamer_id = get_streamer_id(streamer_name)

      if streamer_id
        clips = fetch_clips(streamer_id)
        render json: { data: clips }
      else
        render json: { error: "ユーザーが見つかりませんでした" }, status: :not_found
      end
    end

    private

    # 配信者のユーザーIDを取得する
    def get_streamer_id(streamer_name)
      response = send_twitch_request('users', { login: streamer_name })
      return unless response.success?

      user_data = JSON.parse(response.body)
      user_data['data'].first['id'] if user_data['data'].any?
    end

    # クリップを取得する
    def fetch_clips(streamer_id)
      response = send_twitch_request('clips', { broadcaster_id: streamer_id })
      return [] unless response.success?

      clips = JSON.parse(response.body)["data"]
      clips.select { |clip| clip["language"] == "ja" }
    end

    # 共通のTwitch APIリクエストメソッドmesoddo
    def send_twitch_request(endpoint, params)
      twitch_connection.get(endpoint, params)
    rescue Faraday::Error => e
      Rails.logger.error "Twitch API request failed: #{e.message}"
      OpenStruct.new(success?: false, body: e.message)
    end
  end
end