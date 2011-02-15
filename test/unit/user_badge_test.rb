require 'test_helper'

class UserBadgesTest < ActiveSupport::TestCase
  self.use_instantiated_fixtures  = true
  fixtures :users
  fixtures :clients
  fixtures :badges
  
  def test_create
    ub = UserBadge.new(:user_id => @chad.id, :client_id => @bob.id, :badge_id => @first.id)
    assert ub.save
  end

  def test_bad_create
    ub = UserBadge.new(:client_id => @bob.id, :badge_id => @first.id)
    assert !ub.save
    ub = UserBadge.new(:user_id => @chad.id, :badge_id => @first.id)
    assert !ub.save
    ub = UserBadge.new(:user_id => @chad.id, :client_id => @bob.id)
    assert !ub.save
  end
  
  def test_uniqueness
    UserBadge.delete_all
    ub = UserBadge.new(:user_id => @kilgore.id, :client_id => @bob.id, :badge_id => @first.id)
    assert ub.save
    # can add another badge of the same client
    ub = UserBadge.new(:user_id => @kilgore.id, :client_id => @bob.id, :badge_id => @five.id)
    assert ub.save
    # can add another badge of a different client
    ub = UserBadge.new(:user_id => @kilgore.id, :client_id => @existingbob.id, :badge_id => @beginner.id)
    assert ub.save
    # can't add same badge
    ub = UserBadge.new(:user_id => @kilgore.id, :client_id => @bob.id, :badge_id => @first.id)
    assert !ub.save
  end    
  
end
