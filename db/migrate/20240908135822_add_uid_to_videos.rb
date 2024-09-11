class AddUidToVideos < ActiveRecord::Migration[7.0]
  def change
    add_column :videos, :uid, :string
    add_index :videos, :uid, unique: true
  end
end