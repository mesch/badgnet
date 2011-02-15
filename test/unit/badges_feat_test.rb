require 'test_helper'

class BadgesFeatTest < ActiveSupport::TestCase
  self.use_instantiated_fixtures  = true
  fixtures :badges_feats
  
  def setup
    @c = @bob
    @b = @first
    @f = Feat.new(:client_id => @c.id, :name => 'test')
    @f.save
  end

  def test_create
    bf = BadgesFeat.new(:badge_id => @b.id, :feat_id => @f.id, :threshold => 1)
    assert bf.threshold
    assert bf.save
  end   
  
  def test_missing_fields
    bf = BadgesFeat.new(:badge_id => nil, :feat_id => @f.id, :threshold => 1)
    assert !bf.save
    bf = BadgesFeat.new(:badge_id => @b.id, :feat_id => nil, :threshold => 1)
    assert !bf.save
    bf = BadgesFeat.new(:badge_id => @b.id, :feat_id => @f.id, :threshold => nil)
    assert !bf.save
  end
  
  def test_thresholds
    bf = BadgesFeat.new(:badge_id => @b.id, :feat_id => @f.id, :threshold => -1)
    assert !bf.save
    bf = BadgesFeat.new(:badge_id => @b.id, :feat_id => @f.id, :threshold => 0)
    assert !bf.save
    bf = BadgesFeat.new(:badge_id => @b.id, :feat_id => @f.id, :threshold => 100)
    assert bf.save
  end
  
  def test_same_feats
    bf = BadgesFeat.new(:badge_id => @b.id, :feat_id => @f.id, :threshold => 1)
    assert bf.save
    bf = BadgesFeat.new(:badge_id => @b.id, :feat_id => @f.id, :threshold => 1)
    assert !bf.save     
  end

end