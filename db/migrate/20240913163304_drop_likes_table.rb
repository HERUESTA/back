class DropLikesTable < ActiveRecord::Migration[6.0]
  def up
    drop_table :likes
  end

  def down
    create_table :likes do |t|
      t.bigint :user_id, null: false
      t.bigint :video_id, null: false
      t.timestamps
    end

    add_index :likes, [:user_id, :video_id], unique: true
    add_index :likes, :user_id
    add_index :likes, :video_id

    add_foreign_key :likes, :users
    add_foreign_key :likes, :videos
  end
end