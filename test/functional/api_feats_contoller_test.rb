require 'test_helper'
require 'v1/feats_controller'

# Re-raise errors caught by the controller.
class V1::FeatsController; def rescue_action(e) raise e end; end

class V1::FeatsControllerTest < ActionController::TestCase

  self.use_instantiated_fixtures  = true

  fixtures :clients
  fixtures :users
  fixtures :feats
  
  def test_log
    old_feats = UserFeat.find(:all, :conditions => { :user_id => @kilgore.id, :feat_id => @burger.id, :client_id => @bob.id })
    post :log, :format => :json, :client_id => @bob.id, :api_key => @bob.api_key, :facebook_id => @kilgore.facebook_id, :feat_id => @burger.id
    assert_response :success
    new_feats = UserFeat.find(:all, :conditions => { :user_id => @kilgore.id, :feat_id => @burger.id, :client_id => @bob.id })
    assert_equal new_feats.length, old_feats.length+1
  end
  
  def test_user_creation
    old_users = User.find(:all)
    # add a feat for an existing user
    post :log, :format => :json, :client_id => @bob.id, :api_key => @bob.api_key, :facebook_id => @kilgore.facebook_id, :feat_id => @burger.id
    assert_response :success
    assert_equal old_users.length, User.find(:all).length
    # add a feat for a new user
    post :log, :format => :json, :client_id => @bob.id, :api_key => @bob.api_key, :facebook_id => '1234', :feat_id => @burger.id
    assert_response :success
    assert_equal old_users.length+1, User.find(:all).length
    assert User.find_by_facebook_id('1234')
  end
  
  def test_bad_request
    # missing facebook_id
    post :log, :format => :json, :client_id => @bob.id, :api_key => @bob.api_key, :feat_id => @burger.id
    assert_response :bad_request
    # missing feat_id
    post :log, :format => :json, :client_id => @bob.id, :api_key => @bob.api_key, :facebook_id => @kilgore.facebook_id
    assert_response :bad_request
  end
  
  def test_unauthorized
    # missing client_id
    post :log, :format => :json, :api_key => @bob.api_key, :facebook_id => @kilgore.facebook_id, :feat_id => @burger.id
    assert_response :unauthorized
    # missing api_key
    post :log, :format => :json, :client_id => @bob.id, :facebook_id => @kilgore.facebook_id, :feat_id => @burger.id
    assert_response :unauthorized
    # client_id and api_key don't match
    post :log, :format => :json, :client_id => @bob.id, :api_key => '0123456789', :facebook_id => @kilgore.facebook_id, :feat_id => @burger.id
    assert_response :unauthorized
  end
  
  def test_logout
    assert_nil session[:client_id]
    assert_nil @current_client
    post :log, :format => :json, 
      :client_id => @bob.id, :api_key => @bob.api_key, :facebook_id => @kilgore.facebook_id, :feat_id => @burger.id
    assert_response :success
    assert_nil session[:client_id]
    assert_nil @current_client        
  end
  
end