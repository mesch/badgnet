class UserActions < ActiveRecord::Base
  belongs_to :user
  belongs_to :client
  belongs_to :action

end
