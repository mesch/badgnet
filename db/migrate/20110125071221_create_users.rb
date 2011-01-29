class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string      "first_name",   :limit => 50,   :null => true
      t.string      "last_name",    :limit => 50,   :null => true
      t.integer     "facebook_id",  :limit => 8,    :null => true
      t.boolean     "active",       :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
