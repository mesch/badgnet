require 'test_helper'

class FeatTest < ActiveSupport::TestCase
  self.use_instantiated_fixtures  = true
  fixtures :feats
  
  def setup
    @c = Client.find(:first)
  end

  def test_create
    f = Feat.new(:client_id => @c.id, :name => 'test')
    assert f.active
    assert f.save
  end
  
  def test_empty_fields
    f = Feat.new(:client_id => @c.id, :name => '')
    assert !f.save
  end    
  
  def test_missing_fields
    f = Feat.new(:client_id => nil, :name => 'test')
    assert !f.save
    f = Feat.new(:client_id => @c.id, :name => nil)
    assert !f.save
  end
  
  def test_field_lengths
    f = Feat.new(:client_id => @c.id, :name=> '0123456789012345678901234567890')
    assert !f.save     
  end
  
  def test_active
    f = Feat.new(:client_id => @c.id, :name => 'test')
    f.active = false
    assert f.save    
  end

end  

