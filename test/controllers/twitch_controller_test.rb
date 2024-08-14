require "test_helper"

class TwitchControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get twitch_index_url
    assert_response :success
  end
end
