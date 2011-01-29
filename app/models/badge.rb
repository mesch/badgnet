class Badge < ActiveRecord::Base

  belongs_to :client
  belongs_to :badge_image

  has_many :actions_badges
  has_many :actions, :through => :actions_badges

  has_many :user_badges

end
