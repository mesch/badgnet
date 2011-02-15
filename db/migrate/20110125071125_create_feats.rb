class CreateFeats < ActiveRecord::Migration
  def self.up
    create_table :feats do |t|
      t.integer "client_id"
      t.string  "name"
      t.boolean "active",     :default => true
      t.timestamps
    end
    
    add_index :feats, :client_id
  end

  def self.down
    drop_table :feats
    
    remove_index :feats, :client_id
  end
end
