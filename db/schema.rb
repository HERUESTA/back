# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_09_13_170657) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "liked_videos", force: :cascade do |t|
    t.string "uid", null: false
    t.string "video_id", null: false
    t.string "title"
    t.string "thumbnail_url"
    t.string "video_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid", "video_id"], name: "index_liked_videos_on_uid_and_video_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "followed_streamers"
    t.string "uid"
    t.string "name"
    t.string "token"
    t.string "refresh_token"
    t.datetime "expires_at"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "profile_image_url"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

end
