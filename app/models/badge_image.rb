class BadgeImage < ActiveRecord::Base

  belongs_to :client
  has_many :badges

  def public_images
    q = self.where("user_id is null AND active = true")
  
    return q.order("created_at DESC")
  end

end
