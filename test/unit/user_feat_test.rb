require 'test_helper'

class UserActionsTest < ActiveSupport::TestCase
  self.use_instantiated_fixtures  = true
  fixtures :users
  fixtures :clients
  fixtures :feats
  
  def test_create
    uf = UserFeat.new(:user_id => @kilgore.id, :client_id => @bob.id, :feat_id => @burger.id)
    assert uf.save
  end

  def test_bad_create
    uf = UserFeat.new(:client_id => @bob.id, :feat_id => @burger.id)
    assert !uf.save
    uf = UserFeat.new(:user_id => @kilgore.id, :feat_id => @burger.id)
    assert !uf.save
    uf = UserFeat.new(:user_id => @kilgore.id, :client_id => @bob.id)
    assert !uf.save
  end
  
end
