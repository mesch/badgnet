require 'test_helper'

class BadgeTest < ActiveSupport::TestCase
  self.use_instantiated_fixtures  = true
  fixtures :badges
  
  def setup
    @c = Client.find(:first)
    @bi = BadgeImage.find(:first)
  end

  def test_create
    b = Badge.new(:client_id => @c.id, :name => 'first time', :description => 'welcome, new user!', :badge_image_id => @bi.id)
    assert b.active
    assert b.save
  end
  
  def test_empty_fields
    b = Badge.new(:client_id => @c.id, :name => '', :description => '', :badge_image_id => @bi.id)
    assert !b.save
  end    
  
  def test_missing_fields
    b = Badge.new(:client_id => nil, :name => 'first time', :description => 'welcome, new user!', :badge_image_id => @bi.id)
    assert !b.save
    b = Badge.new(:client_id => @c.id, :name => nil, :description => 'welcome, new user!', :badge_image_id => @bi.id)
    assert !b.save
    b = Badge.new(:client_id => @c.id, :name => 'first time', :description => nil, :badge_image_id => @bi.id)
    assert !b.save
    b = Badge.new(:client_id => @c.id, :name => 'first time', :description => 'welcome, new user!', :badge_image_id => nil)
    assert !b.save
  end
  
  def test_field_lengths
    b = Badge.new(:client_id => @c.id, :name => '0123456789012345678901234567890', :description => 'test', :badge_image_id => @bi.id)   
    assert !b.save
    b = Badge.new(:client_id => @c.id, :name => 'test', :badge_image_id => @bi.id)
    b.description = '012345678901234567890123456789012345678901234567890' 
    assert !b.save        
  end
  
  def test_active
    b = Badge.new(:client_id => @c.id, :name => 'test', :description => 'test', :badge_image_id => @bi.id)
    b.active = false
    assert b.save    
  end

end
