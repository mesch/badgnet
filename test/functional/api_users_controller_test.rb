require 'test_helper'
require 'v1/users_controller'

# Re-raise errors caught by the controller.
class V1::UsersController; def rescue_action(e) raise e end; end

class V1::UsersControllerTest < ActionController::TestCase

  self.use_instantiated_fixtures  = true

  fixtures :clients
  fixtures :users
  fixtures :feats        
  
  def test_bad_request
    # missing facebook_id
    get :badges, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key
    assert_response :bad_request
  end
  
end