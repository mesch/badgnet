class BadgesFeat < ActiveRecord::Base
  validates_presence_of :badge_id, :feat_id
  validates_numericality_of :threshold, :only_integer => true, :greater_than_or_equal_to => 1
  validates_uniqueness_of :feat_id, :scope => [:badge_id]

  belongs_to :badge
  belongs_to :feat
  
  def as_json(options={})
    { :feat_id => self.feat.id, :client_id => self.feat.client_id, :name => self.feat.name, :threshold => self.threshold }
  end

end
