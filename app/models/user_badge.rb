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
  
  def self.top_badges(client_id, start_date, end_date)
    # gotta be a better way to do this, but oh well ...
    start_time = Time.zone.parse(start_date.to_s)
    end_time = Time.zone.parse(end_date.to_s).end_of_day
    # this comes back as an OrderedHash - a little weird
    badges = UserBadge.count(
      :conditions => ["user_badges.client_id = ? AND user_badges.created_at BETWEEN ? AND ?", client_id, start_time, end_time],
      :group => :badge_id,
      :order => "count(*) desc")
    results = []
    for badge in badges
      results << {:badge_id => badge[0], :badge_name => Badge.find(badge[0]).name, :badges => badge[1]}
    end
    return results
  end

end
