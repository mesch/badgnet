class UserFeat < ActiveRecord::Base
  validates_presence_of :user_id, :client_id, :feat_id

  belongs_to :user
  belongs_to :client
  belongs_to :feat

  def as_json(options={})
    { :client_id => self.client_id, :feat_id => self.feat_id, :timestamp => self.created_at }
  end

end
