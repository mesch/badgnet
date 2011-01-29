class ActionsBadge < ActiveRecord::Base
  belongs_to :badge
  belongs_to :action

end
