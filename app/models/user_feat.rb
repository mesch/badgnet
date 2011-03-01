class UserFeat < ActiveRecord::Base
  validates_presence_of :user_id, :client_id, :feat_id

  belongs_to :user
  belongs_to :client
  belongs_to :feat

  def as_json(options={})
    { :client_id => self.client_id, :feat_id => self.feat_id, 
      :timestamp => self.created_at.strftime(OPTIONS[:time_format]) }
  end
  
  def self.top_feats(client_id, start_date, end_date)
    # gotta be a better way to do this, but oh well ...
    start_time = Time.zone.parse(start_date.to_s)
    end_time = Time.zone.parse(end_date.to_s).end_of_day
    # this comes back as an OrderedHash - a little weird
    feats = UserFeat.count(
      :conditions => ["user_feats.client_id = ? AND user_feats.created_at BETWEEN ? AND ?", client_id, start_time, end_time],
      :group => :feat_id,
      :order => "count(*) desc")
    results = []
    for feat in feats
      results << {:feat_id => feat[0], :feat_name => Feat.find(feat[0]).name, :feats => feat[1]}
    end
    return results
  end

end
