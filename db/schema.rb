# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110125071303) do

  create_table "actions", :force => true do |t|
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "actions_badges", :force => true do |t|
    t.integer  "badge_id"
    t.integer  "action_id"
    t.integer  "threshold"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "badge_images", :force => true do |t|
    t.integer  "client_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.string   "image_file_size"
    t.boolean  "active",             :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "badges", :force => true do |t|
    t.integer  "client_id",                                      :null => false
    t.string   "name",           :limit => 30,                   :null => false
    t.string   "description",    :limit => 80,                   :null => false
    t.boolean  "active",                       :default => true
    t.integer  "badge_image_id"
    t.integer  "limit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clients", :force => true do |t|
    t.string   "name"
    t.string   "username"
    t.string   "hashed_password"
    t.string   "email"
    t.string   "salt"
    t.boolean  "active",          :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_actions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "client_id"
    t.integer  "action_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_badges", :force => true do |t|
    t.integer  "user_id"
    t.integer  "client_id"
    t.integer  "badge_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name",  :limit => 50
    t.string   "last_name",   :limit => 50
    t.integer  "facebook_id", :limit => 8
    t.boolean  "active",                    :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
