class CreateBadges < ActiveRecord::Migration
  def self.up
    create_table :badges do |t|
      t.integer   "client_id",    :null => false
      t.string    "name",         :limit => 30,   :null => false
      t.string    "description",  :limit => 80,   :null => false
      t.boolean   "active",        :default => true
      t.integer   "badge_image_id"
      t.integer   "limit" 
      t.timestamps
    end
  end

  def self.down
    drop_table :badges
  end
end
