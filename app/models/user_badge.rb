class UserBadge < ActiveRecord::Base
  validates_presence_of :user_id, :client_id, :badge_id
  validates_uniqueness_of :user_id, :scope => [:client_id, :badge_id]

  belongs_to :user
  belongs_to :client
  belongs_to :badge

  def as_json(options={})
    # include timestamp?
    { :badge_id => self.badge_id, :client_id => self.client_id }
  end

end
