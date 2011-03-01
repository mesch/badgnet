require 'test_helper'
require 'v1/clients_controller'

# Re-raise errors caught by the controller.
class V1::ClientsController; def rescue_action(e) raise e end; end

class V1::ClientsControllerTest < ActionController::TestCase

  self.use_instantiated_fixtures  = true

  fixtures :clients
  
  def setup
    Feat.delete_all
    Badge.delete_all  
  end
  
  def test_feats
    # no data
    response = get :feats, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key
    assert_response :success
    assert empty_response(response.body)
    # one feat
    f1 = Feat.create(:client_id => @existingbob.id, :name => 'test')
    response = get :feats, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key
    assert_response :success
    data = ActiveSupport::JSON.decode(response.body)
    assert validate_feat(data[0], f1)
    # add another feat
    f2 = Feat.create(:client_id => @existingbob.id, :name => 'test2')
    response = get :feats, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key
    assert_response :success
    data = ActiveSupport::JSON.decode(response.body)
    assert validate_feat(data[0], f1)
    assert validate_feat(data[1], f2)
  end
  
  def test_badges_no_feats
    # no data
    response = get :badges, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key
    assert_response :success
    assert empty_response(response.body)
    # one badge
    b = Badge.create(:client_id => @existingbob.id, :badge_image_id => 1, :name => 'test', :description => 'testtest', 
      :active => true)
    response = get :badges, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key
    assert_response :success
    data = ActiveSupport::JSON.decode(response.body)
    assert validate_badge(data[0], b) 
  end
  
  def test_badges_with_feats
    b = Badge.create(:client_id => @existingbob.id, :badge_image_id => 1, :name => 'test', :description => 'testtest', 
      :active => true)
    f = Feat.create(:client_id => @existingbob.id, :name => 'test')
    bf = BadgesFeat.create(:badge_id => b.id, :feat_id => f.id)
    response = get :badges, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key
    assert_response :success
    data = ActiveSupport::JSON.decode(response.body)
    assert validate_badge(data[0], b)
  end

private

  def empty_response(json)
    data = ActiveSupport::JSON.decode(json)
    return data == [] ? true : false
  end

  def validate_feat(data, feat)
    if data["client_id"] == feat.client_id && data["name"] == feat.name
      return true
    end
    return false
  end

  # only validates one feat for a badge - for now
  def validate_badge(data, badge)
    if data["client_id"] == badge.client_id && data["badge_id"] == badge.id && data["name"] == badge.name &&
      data["description"] == badge.description && data["image"] == badge.badge_image.image.url(:thumb) &&
      data["feats"].length == badge.feats.length
      if data["feats"].length == 0
        return true
      end
      if data["feats"].length > 0 && validate_feat(data["feats"][0] == badge.feats[0])
        return true
      end
    end
    return false
  end
  
end