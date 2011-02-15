class CreateUserFeats < ActiveRecord::Migration
  def self.up
    create_table :user_feats do |t|
      t.integer     "user_id"
      t.integer     "client_id"
      t.integer     "feat_id"
      t.timestamps
    end
    
    add_index :user_feats, [:user_id, :client_id], :name => 'user_feats_by_user_client'
    add_index :user_feats, :client_id
  end

  def self.down
    drop_table :user_feats
    
    remove_index :user_feats, 'user_feats_by_user_client'
    remove_index :user_feats, :client_id
  end
end
