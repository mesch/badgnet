class UserBadges < ActiveRecord::Base
  belongs_to :user
  belongs_to :client
  belongs_to :badge

end
