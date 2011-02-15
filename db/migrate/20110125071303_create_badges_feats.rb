class CreateBadgesFeats < ActiveRecord::Migration
  def self.up
    create_table :badges_feats do |t|
      t.integer     "badge_id"
      t.integer     "feat_id"
      t.integer     "threshold"
      t.timestamps
    end
    
    add_index :badges_feats, :badge_id
    add_index :badges_feats, :feat_id
  end

  def self.down
    drop_table :badges_feats
    
    remove_index :badges_feats, :badge_id
    remove_index :badges_feats, :feat_id
  end
end
