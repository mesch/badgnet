class CreateBadgeImages < ActiveRecord::Migration
  def self.up
    create_table :badge_images do |t|
      t.integer     "client_id"
      t.string      "image_file_name"
      t.string      "image_content_type"
      t.string      "image_file_size"
      t.boolean     "active",              :default => true
      t.timestamps
    end
    
    add_index :badge_images, :client_id
  end

  def self.down
    drop_table :badge_images
    
    remove_index :badge_images, :client_id
  end
end
