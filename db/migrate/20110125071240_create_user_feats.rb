class CreateUserFeats < ActiveRecord::Migration
  def self.up
    create_table :user_feats do |t|
      t.integer     "user_id"
      t.integer     "client_id"
      t.integer     "feat_id"
      t.timestamps
    end
  end

  def self.down
    drop_table :user_feats
  end
end
