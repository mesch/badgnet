class CreateUserActions < ActiveRecord::Migration
  def self.up
    create_table :user_actions do |t|
      t.integer     "user_id"
      t.integer     "client_id"
      t.integer     "action_id"
      t.timestamps
    end
  end

  def self.down
    drop_table :user_actions
  end
end
