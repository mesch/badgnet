class User < ActiveRecord::Base

  has_many :user_badges
  has_many :user_actions

  def full_name
    return "#{self.first_name} #{self.last_name}"
  end

end
