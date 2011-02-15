class CreateBadges < ActiveRecord::Migration
  def self.up
    create_table :badges do |t|
      t.integer   "client_id"
      t.string    "name"
      t.string    "description"
      t.boolean   "active",        :default => true
      t.integer   "badge_image_id"
      t.timestamps
    end
    
    add_index :badges, :client_id
  end

  def self.down
    drop_table :badges
    
    remove_index :badges, :client_id
  end
end
