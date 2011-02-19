class Badge < ActiveRecord::Base
  validates_length_of :name,        :maximum => 30
  validates_length_of :description, :maximum => 50
  validates_presence_of :client_id, :name, :description, :badge_image_id
  
  attr_protected :id
  
  belongs_to :client
  belongs_to :badge_image

  has_many :badges_feats
  has_many :feats, :through => :badges_feats

  has_many :user_badges
 
  def as_json(options={})
    { :badge_id => self.id, :client_id => self.client_id, :name => self.name, :description => self.description,
      :image => self.badge_image.image.url(:thumb), :feats => self.badges_feats }
  end

  def get_image(params = {})
    image_type = params[:image_type] || :thumb
    # Proxy around badge image
    if (self.badge_image && self.badge_image.image)
      # The badge has an image. Return it.
      self.badge_image.image.url(image_type)
    else 
      # Return default image as server host + default badge image location
      OPTIONS[:default_badge_image]
    end
  end
  
  def display_active()
    if self.active
      return "Active"
    else
      return "Inactive"
    end
  end
  
end
