class CreateBadgeImages < ActiveRecord::Migration
  def self.up
    create_table :badge_images do |t|
      t.integer     "client_id",           :null => true
      t.string      "image_file_name"
      t.string      "image_content_type"
      t.string      "image_file_size"
      t.boolean     "active",              :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :badge_images
  end
end
