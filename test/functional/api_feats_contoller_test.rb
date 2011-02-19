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
  
  # user creation
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

  # badge update
  def test_badge_update_one_feat
    user = User.find(@kilgore)
    # delete all user badges and user feats for one client
    UserFeat.delete_all("user_id = #{@kilgore.id} and client_id = #{@existingbob.id}")
    UserBadge.delete_all("user_id = #{@kilgore.id} and client_id = #{@existingbob.id}")    
    badges = user.user_badges_by_client_id(@existingbob.id)
    badges2 = user.user_badges_by_client_id(@bob.id)      # Using this to see that other client badges are not affected
    assert_equal badges.length, 0
    assert_not_equal badges2.length, 0    
    # add a single feat for beginner badge
    assert_difference('Delayed::Job.count') do
      post :log, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, 
        :facebook_id => user.facebook_id, :feat_id => @view_trailer.id      
    end
    Delayed::Worker.new.work_off
    assert_equal user.user_badges_by_client_id(@existingbob.id).length, badges.length+1
    assert_equal user.user_badges_by_client_id(@bob.id).length, badges2.length
    assert user.user_badges_by_client_id_grouped(@existingbob.id)[@beginner.id]
  end

  def test_badge_update_no_repitition
    user = User.find(@kilgore)
    # delete all user badges and user feats for one client
    UserFeat.delete_all("user_id = #{@kilgore.id} and client_id = #{@existingbob.id}")
    UserBadge.delete_all("user_id = #{@kilgore.id} and client_id = #{@existingbob.id}")    
    badges = user.user_badges_by_client_id(@existingbob.id)
    badges2 = user.user_badges_by_client_id(@bob.id)      # Using this to see that other client badges are not affected
    assert_equal badges.length, 0
    assert_not_equal badges2.length, 0    
    # add a single feat for beginner badge
    assert_difference('Delayed::Job.count') do
      post :log, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, 
      :facebook_id => user.facebook_id, :feat_id => @view_trailer.id
    end
    Delayed::Worker.new.work_off
    # should add badge   
    assert_equal user.user_badges_by_client_id(@existingbob.id).length, badges.length+1
    assert_equal user.user_badges_by_client_id(@bob.id).length, badges2.length
    assert user.user_badges_by_client_id_grouped(@existingbob.id)[@beginner.id]
    # add another feat for beginner badge
    assert_difference('Delayed::Job.count') do
      post :log, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, 
      :facebook_id => user.facebook_id, :feat_id => @view_trailer.id
    end
    Delayed::Worker.new.work_off
    # shouldn't add another badge
    assert_equal user.user_badges_by_client_id(@existingbob.id).length, badges.length+1
    assert_equal user.user_badges_by_client_id(@bob.id).length, badges2.length
    assert user.user_badges_by_client_id_grouped(@existingbob.id)[@beginner.id]    
  end
  
  def test_badge_update_many_feats
    user = User.find(@kilgore)
    # delete all user badges and user feats for one client
    UserFeat.delete_all("user_id = #{@kilgore.id} and client_id = #{@existingbob.id}")
    UserBadge.delete_all("user_id = #{@kilgore.id} and client_id = #{@existingbob.id}")    
    badges = user.user_badges_by_client_id(@existingbob.id)
    badges2 = user.user_badges_by_client_id(@bob.id)      # Using this to see that other client badges are not affected
    assert_equal badges.length, 0
    assert_not_equal badges2.length, 0    
    # add 4 feats for advanced badge (requires 5)
    assert_difference('Delayed::Job.count') do
      post :log, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, 
      :facebook_id => user.facebook_id, :feat_id => @share_trailer.id
    end
    assert_difference('Delayed::Job.count') do
      post :log, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, 
      :facebook_id => user.facebook_id, :feat_id => @share_trailer.id
    end
    assert_difference('Delayed::Job.count') do
      post :log, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, 
      :facebook_id => user.facebook_id, :feat_id => @share_trailer.id
    end
    assert_difference('Delayed::Job.count') do
      post :log, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, 
      :facebook_id => user.facebook_id, :feat_id => @share_trailer.id
    end
    Delayed::Worker.new.work_off
    # shouldn't award advanced badge
    assert_equal user.user_badges_by_client_id(@existingbob.id).length, badges.length
    assert_equal user.user_badges_by_client_id(@bob.id).length, badges2.length
    assert_nil user.user_badges_by_client_id_grouped(@existingbob.id)[@advanced.id]    
    # add 5th
    assert_difference('Delayed::Job.count') do
      post :log, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, 
      :facebook_id => user.facebook_id, :feat_id => @share_trailer.id
    end
    Delayed::Worker.new.work_off
    # should award advanced badge
    assert_equal user.user_badges_by_client_id(@existingbob.id).length, badges.length+1
    assert_equal user.user_badges_by_client_id(@bob.id).length, badges2.length
    assert user.user_badges_by_client_id_grouped(@existingbob.id)[@advanced.id]
    # add 1 feat for expert badge
    assert_difference('Delayed::Job.count') do
      post :log, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, 
      :facebook_id => user.facebook_id, :feat_id => @write_review.id
    end
    Delayed::Worker.new.work_off
    # should award expert badge
    assert_equal user.user_badges_by_client_id(@existingbob.id).length, badges.length+2
    assert_equal user.user_badges_by_client_id(@bob.id).length, badges2.length
    assert user.user_badges_by_client_id_grouped(@existingbob.id)[@advanced.id]      
    assert user.user_badges_by_client_id_grouped(@existingbob.id)[@expert.id]     
  end
  
  def test_badge_update_no_feats
    user = User.find(@kilgore)
    badges = user.user_badges_by_client_id(@existingbob.id)
    badges2 = user.user_badges_by_client_id(@bob.id)
    assert_not_equal badges.length, 0
    assert_not_equal badges2.length, 0
    # add a badge with no feats
    image = BadgeImage.find(:first)
    badge = Badge.new(:name => "empty badge", :client_id => @existingbob.id, :description => "test", :badge_image_id => image.id)
    assert badge.save
    # adding a feat (in the case for this user's current feats) shouldn't add more
    assert_difference('Delayed::Job.count') do
      post :log, :format => :json, :client_id => @existingbob.id, :api_key => @existingbob.api_key, 
      :facebook_id => user.facebook_id, :feat_id => @view_trailer.id
    end
    Delayed::Worker.new.work_off
    assert_response :success
    assert_equal badges.length, user.user_badges_by_client_id(@existingbob.id).length
    assert_equal badges2.length, user.user_badges_by_client_id(@bob.id).length
  end

  # General API tests - here for now
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