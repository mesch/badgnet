class CreateActionsBadges < ActiveRecord::Migration
  def self.up
    create_table :actions_badges do |t|
      t.integer     "badge_id"
      t.integer     "action_id"
      t.integer     "threshold"
      t.timestamps
    end
  end

  def self.down
    drop_table :actions_badges
  end
end
