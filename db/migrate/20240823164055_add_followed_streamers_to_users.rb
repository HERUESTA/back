class AddFollowedStreamersToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :followed_streamers, :json
  end
end
