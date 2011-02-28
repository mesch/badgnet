class AddClientTimezone < ActiveRecord::Migration
  def self.up
    add_column :clients, :time_zone, :string, :default => "Pacific Time (US & Canada)"
  end

  def self.down
    remove_column :clients, :time_zone
  end
end
