class CreateClients < ActiveRecord::Migration
  def self.up
    create_table :clients do |t|
      t.string      "name"
      t.string      "username"
      t.string      "hashed_password"
      t.string      "email"
      t.string      "salt"
      t.string      "activation_code"
      t.boolean     "activated",  :default => false
      t.string      "api_key"
      t.boolean     "active",     :default => true
      t.timestamps
    end
    
    add_index :clients, :username
  end

  def self.down
    drop_table :clients
    
    remove_index :clients, :username
  end
end
