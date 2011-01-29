class Action < ActiveRecord::Base

  has_many :actions_badges
  has_many :badges, :through => :actions_badges
  
  has_many :user_actions

end
