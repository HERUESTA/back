# app/controllers/twitch_controller.rb
class TwitchController < ApplicationController
  require 'net/http'
  require 'uri'
  require 'json'

  def show
    streamer_name = params[:id]
    user_id = get_user_id(streamer_name)
    
    if user_id.nil?
      render json: { error: "User not found" }, status: :not_found
      return
    end

    uri = URI("https://api.twitch.tv/helix/clips?broadcaster_id=#{user_id}")
    request = Net::HTTP::Get.new(uri)
    request['Client-ID'] = ENV['TWITCH_CLIENT_ID']
    request['Authorization'] = "Bearer #{ENV['TWITCH_ACCESS_TOKEN']}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    if response.is_a?(Net::HTTPSuccess)
      render json: JSON.parse(response.body)
    else
      render json: { error: response.message, body: response.body, status_code: response.code }, status: response.code
    end
  end

  private

  def get_user_id(streamer_name)
    uri = URI("https://api.twitch.tv/helix/users?login=#{streamer_name}")
    request = Net::HTTP::Get.new(uri)
    request['Client-ID'] = ENV['TWITCH_CLIENT_ID']
    request['Authorization'] = "Bearer #{ENV['TWITCH_ACCESS_TOKEN']}"
  
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
  
    if response.is_a?(Net::HTTPSuccess)
      user_data = JSON.parse(response.body)
      puts "User data: #{user_data}"  # デバッグ用の出力
      user_data['data'].first['id'] if user_data['data'].any?
    else
      puts "Failed to get user ID: #{response.message}"  # デバッグ用の出力
      nil
    end
  end
end