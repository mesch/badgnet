require 'test_helper'

class BadgeImageTest < ActiveSupport::TestCase
  self.use_instantiated_fixtures  = true
  fixtures :badge_images

  def setup
    @c = Client.find(:first)
  end

  def test_public_image
    bi = BadgeImage.new(
      :image_file_name => 'silver_star.png', 
      :image_content_type => 'image/png',
      :image_file_size => 15039)    
    assert bi.active
    assert_nil bi.client_id
    assert bi.save
  end
  
  def test_client_image
    bi = BadgeImage.new(
      :client_id => @c.id,
      :image_file_name => 'silver_star.png', 
      :image_content_type => 'image/png',
      :image_file_size => 15039)    
    assert bi.active
    assert_not_nil bi.client_id
    assert bi.save    
  end
  
end
