class BadgesInactive < ActiveRecord::Migration
  def self.up
    change_column(:badges, :active, :boolean, :default => false)
  end

  def self.down
    change_column(:badges, :active, :boolean, :default => true)    
  end
end
