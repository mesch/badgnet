require 'test_helper'
require 'v1/users_controller'

# Re-raise errors caught by the controller.
class V1::UsersController; def rescue_action(e) raise e end; end

class V1::UsersControllerTest < ActionController::TestCase

  self.use_instantiated_fixtures  = true

  fixtures :clients
  fixtures :users
  fixtures :feats
  fixtures :badges    
  
  def setup
    UserBadge.delete_all
    UserFeat.delete_all
  end
  
  def test_bad_request
    # missing facebook_id
    get :feats, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key
    assert_response :bad_request
    # missing facebook_id
    get :badges, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key
    assert_response :bad_request
  end
  
  def test_feats
    # no data
    response = get :feats, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, 
      :facebook_id => @kilgore.facebook_id
    assert_response :success
    assert empty_response(response.body)
    response = get :feats, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, 
      :facebook_id => @chad.facebook_id
    assert_response :success    
    assert empty_response(response.body)
    # one feat
    f1 = UserFeat.create(:client_id => @existingbob.id, :user_id => @kilgore.id, :feat_id => @view_trailer.id)
    response = get :feats, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, 
      :facebook_id => @kilgore.facebook_id
    assert_response :success
    data = ActiveSupport::JSON.decode(response.body)
    assert validate_feat(data[0], f1)
    response = get :feats, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, 
        :facebook_id => @chad.facebook_id
    assert_response :success
    assert empty_response(response.body)
    # add another of same feat
    f2 = UserFeat.create(:client_id => @existingbob.id, :user_id => @kilgore.id, :feat_id => @view_trailer.id)
    response = get :feats, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, 
      :facebook_id => @kilgore.facebook_id
    assert_response :success
    data = ActiveSupport::JSON.decode(response.body)
    assert validate_feat(data[0], f1)
    assert validate_feat(data[1], f2)
    response = get :feats, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, 
        :facebook_id => @chad.facebook_id
    assert_response :success
    assert empty_response(response.body)
    # add a different feat
    f3 = UserFeat.create(:client_id => @existingbob.id, :user_id => @kilgore.id, :feat_id => @share_trailer.id)
    response = get :feats, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, 
      :facebook_id => @kilgore.facebook_id
    assert_response :success
    data = ActiveSupport::JSON.decode(response.body)
    assert validate_feat(data[0], f1)
    assert validate_feat(data[1], f2)
    assert validate_feat(data[2], f3)
    response = get :feats, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, 
        :facebook_id => @chad.facebook_id
    assert_response :success
    assert empty_response(response.body)  
  end
  
  def test_badges
    # no data
    response = get :badges, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, 
      :facebook_id => @kilgore.facebook_id
    assert_response :success
    assert empty_response(response.body)
    response = get :badges, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, 
      :facebook_id => @chad.facebook_id
    assert_response :success    
    assert empty_response(response.body)
    # one badge
    b1 = UserBadge.create(:client_id => @existingbob.id, :user_id => @kilgore.id, :badge_id => @beginner.id)
    response = get :badges, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, 
      :facebook_id => @kilgore.facebook_id
    assert_response :success
    data = ActiveSupport::JSON.decode(response.body)
    assert validate_badge(data[0], b1)
    response = get :badges, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, 
        :facebook_id => @chad.facebook_id
    assert_response :success
    assert empty_response(response.body)
    # add a different badge
    b2 = UserBadge.create(:client_id => @existingbob.id, :user_id => @kilgore.id, :badge_id => @advanced.id)
    response = get :badges, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, 
      :facebook_id => @kilgore.facebook_id
    assert_response :success
    data = ActiveSupport::JSON.decode(response.body)
    assert validate_badge(data[0], b1)
    assert validate_badge(data[1], b2)
    response = get :badges, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, 
        :facebook_id => @chad.facebook_id
    assert_response :success
    assert empty_response(response.body)    
  end

private

  def empty_response(json)
    data = ActiveSupport::JSON.decode(json)
    return data == [] ? true : false
  end

  def validate_feat(data, feat)
    # oddities with the timestamp - data will be in client_timezone - convert to utc
    Time.zone = @existingbob.time_zone
    if Time.zone.parse(data["timestamp"]).utc == Time.zone.parse(feat.created_at.to_s).utc &&
      data["client_id"] == feat.client_id && data["feat_id"] == feat.feat_id
      return true
    end
    return false
  end
  
  def validate_badge(data, badge)
    if data["client_id"] == badge.client_id && data["badge_id"] == badge.badge_id
      return true
    end
    return false
  end
  
end