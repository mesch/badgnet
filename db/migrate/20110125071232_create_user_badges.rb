class CreateUserBadges < ActiveRecord::Migration
  def self.up
    create_table :user_badges do |t|
      t.integer     "user_id"
      t.integer     "client_id"
      t.integer     "badge_id"
      t.timestamps
    end
    
    add_index :user_badges, [:user_id, :client_id], :name => 'by_user_client'
    add_index :user_badges, :client_id
  end

  def self.down
    drop_table :user_badges
    
    remove_index :user_badges, 'by_user_client'
    remove_index :user_badges, :client_id
  end
end
