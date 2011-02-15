class FixIndices < ActiveRecord::Migration
  def self.up
    remove_index :user_badges, 'by_user_client'
    remove_index :user_badges, :client_id
    add_index :user_feats, [:user_id, :client_id], :name => 'user_feats_by_user_client'
    add_index :user_feats, :client_id
    add_index :user_badges, [:user_id, :client_id], :name => 'user_badges_by_user_client'
    add_index :user_badges, :client_id
  end

  def self.down
    remove_index :user_feats, 'user_feats_by_user_client'
    remove_index :user_feats, :client_id
    add_index :user_badges, [:user_id, :client_id], :name => 'user_badges_by_user_client'
    add_index :user_badges, :client_id
  end
end
