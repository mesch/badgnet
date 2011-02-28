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

ActiveRecord::Schema.define(:version => 20110225005922) do

  create_table "badge_images", :force => true do |t|
    t.integer  "client_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.string   "image_file_size"
    t.boolean  "active",             :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "badge_images", ["client_id"], :name => "index_badge_images_on_client_id"

  create_table "badges", :force => true do |t|
    t.integer  "client_id"
    t.string   "name"
    t.string   "description"
    t.boolean  "active",         :default => false
    t.integer  "badge_image_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "badges", ["client_id"], :name => "index_badges_on_client_id"

  create_table "badges_feats", :force => true do |t|
    t.integer  "badge_id"
    t.integer  "feat_id"
    t.integer  "threshold"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "badges_feats", ["badge_id"], :name => "index_badges_feats_on_badge_id"
  add_index "badges_feats", ["feat_id"], :name => "index_badges_feats_on_feat_id"

  create_table "client_stats", :force => true do |t|
    t.integer  "client_id"
    t.date     "day"
    t.integer  "users"
    t.integer  "user_badges"
    t.integer  "user_feats"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "client_stats", ["client_id", "day"], :name => "client_stats_by_client_day"

  create_table "clients", :force => true do |t|
    t.string   "name"
    t.string   "username"
    t.string   "hashed_password"
    t.string   "email"
    t.string   "salt"
    t.string   "activation_code"
    t.boolean  "activated",       :default => false
    t.string   "api_key"
    t.boolean  "active",          :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_zone",       :default => "Pacific Time (US & Canada)"
  end

  add_index "clients", ["username"], :name => "index_clients_on_username"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "feats", :force => true do |t|
    t.integer  "client_id"
    t.string   "name"
    t.boolean  "active",     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feats", ["client_id"], :name => "index_feats_on_client_id"

  create_table "user_badges", :force => true do |t|
    t.integer  "user_id"
    t.integer  "client_id"
    t.integer  "badge_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_badges", ["client_id"], :name => "index_user_badges_on_client_id"
  add_index "user_badges", ["user_id", "client_id"], :name => "user_badges_by_user_client"

  create_table "user_feats", :force => true do |t|
    t.integer  "user_id"
    t.integer  "client_id"
    t.integer  "feat_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_feats", ["client_id"], :name => "index_user_feats_on_client_id"
  add_index "user_feats", ["user_id", "client_id"], :name => "user_feats_by_user_client"

  create_table "users", :force => true do |t|
    t.string   "first_name",  :limit => 50
    t.string   "last_name",   :limit => 50
    t.integer  "facebook_id", :limit => 8
    t.boolean  "active",                    :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["facebook_id"], :name => "index_users_on_facebook_id", :unique => true

end
