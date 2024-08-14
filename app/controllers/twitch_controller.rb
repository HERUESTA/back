require 'httparty'

class TwitchController < ApplicationController
  def index
    streamer_id = params[:id]
    access_token = fetch_access_token
    videos = fetch_videos(streamer_id, access_token)

    render json: videos
  end

  private

  def fetch_access_token
    response = HTTParty.post('https://id.twitch.tv/oauth2/token', {
      body: {
        client_id: ENV['TWITCH_CLIENT_ID'],
        client_secret: ENV['TWITCH_CLIENT_SECRET'],
        grant_type: 'client_credentials'
      }
    })
    response.parsed_response['access_token']
  end

  def fetch_videos(streamer_id, access_token)
    response = HTTParty.get("https://api.twitch.tv/helix/videos?user_id=#{streamer_id}", {
      headers: {
        'Client-ID' => ENV['TWITCH_CLIENT_ID'],
        'Authorization' => "Bearer #{access_token}"
      }
    })
    response.parsed_response['data']
  end
end