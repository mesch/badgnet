require 'test_helper'
require 'v1/users_controller'

# Re-raise errors caught by the controller.
class V1::UsersController; def rescue_action(e) raise e end; end

class V1::UsersControllerTest < ActionController::TestCase

  self.use_instantiated_fixtures  = true

  fixtures :clients
  fixtures :users
  fixtures :feats
  
  def test_badge_update
    user = User.find(@kilgore)
    badges = user.user_badges_by_client_id(@existingbob.id)
    badges2 = user.user_badges_by_client_id(@bob.id)
    assert_not_equal badges.length, 0
    assert_not_equal badges2.length, 0    
    # updating shouldn't add anymore
    get :badges, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, :facebook_id => @kilgore.facebook_id
    assert_response :success
    assert_equal badges.length, user.user_badges_by_client_id(@existingbob.id).length
    assert_equal badges2.length, user.user_badges_by_client_id(@bob.id).length
    # deleting a badge with one feat
    UserBadge.delete(@beginner_kilgore.id)
    assert_nil user.user_badges_by_client_id_grouped(@existingbob.id)[@beginner.id]
    assert_equal badges.length, user.user_badges_by_client_id(@existingbob.id).length+1
    assert_equal badges2.length, user.user_badges_by_client_id(@bob.id).length 
    # updating should add it back
    get :badges, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, :facebook_id => @kilgore.facebook_id
    assert_response :success
    assert user.user_badges_by_client_id_grouped(@existingbob.id)[@beginner.id]
    assert_equal badges.length, user.user_badges_by_client_id(@existingbob.id).length    
    assert_equal badges2.length, user.user_badges_by_client_id(@bob.id).length
  end
  
  def test_bad_request
    # missing facebook_id
    get :badges, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key
    assert_response :bad_request
  end
  
end