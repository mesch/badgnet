class Feat < ActiveRecord::Base
  validates_length_of :name, :maximum => 30
  validates_presence_of :client_id, :name

  attr_protected :id
  
  belongs_to :client
  
  has_many :badges_feats
  has_many :badges, :through => :badges_feats
  
  has_many :user_feats
  
  def as_json(options={})
    { :feat_id => self.id, :client_id => self.client_id, :name => self.name }
  end

end
