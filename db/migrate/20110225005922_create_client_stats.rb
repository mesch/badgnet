class CreateClientStats < ActiveRecord::Migration
  def self.up
    create_table :client_stats do |t|
      t.integer   "client_id"
      t.date      "day"
      t.integer   "users"
      t.integer   "user_badges"
      t.integer   "user_feats"
      t.timestamps
    end
    
    add_index :client_stats, [:client_id, :day], :name => 'client_stats_by_client_day'
  end
  

  def self.down
    drop_table :client_stats
    
    remove_index :client_stats, 'client_stats_by_client_day'
  end
end