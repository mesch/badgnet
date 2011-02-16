require 'test_helper'
require 'client_controller'

# Re-raise errors caught by the controller.
class ClientController; def rescue_action(e) raise e end; end

class ClientControllerTest < ActionController::TestCase

  self.use_instantiated_fixtures  = true

  fixtures :clients
  fixtures :badges
  fixtures :feats
  fixtures :badge_images

  def setup
    @controller = ClientController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "localhost"
  end

  def login
    post :login, :username => "bob", :password => "test"
  end
    
  def test_auth_bob
    #check we can login
    post :login, :username => "bob", :password => "test"
    assert session[:client_id]
    assert_equal @bob, Client.find(session[:client_id])
    assert_response :redirect
    assert_redirected_to :action=>'home'
  end

  def test_signup
    #unfortunately can't test passing captcha - this will fail for now
    post :signup, :username => "newbob", :password => "newpassword", :password_confirmation => "newpassword", :email => "newbob@mcbob.com" 
    assert_response :success
    assert_nil session[:client_id]
    assert flash[:warning]
    assert_template "client/signup"
  end

  def test_bad_signup
    #check we can't signup without all required fields
    post :signup, :username => "newbob", :password => "newpassword", :password_confirmation => "wrong" , :email => "newbob@mcbob.com"
    assert_response :success
    assert_template "client/signup"
    assert_nil session[:client_id]

    post :signup, :username => "yo", :password => "newpassword", :password_confirmation => "newpassword" , :email => "newbob@mcbob.com"
    assert_response :success
    assert_template "client/signup"
    assert_nil session[:client_id]

    post :signup, :username => "yo", :password => "newpassword", :password_confirmation => "wrong" , :email => "newbob@mcbob.com"
    assert_response :success
    assert_template "client/signup"
    assert_nil session[:client_id]
  end

  def test_invalid_login
    #can't login with incorrect password
    post :login, :username => "bob", :password => "not_correct"
    assert_response :success
    assert_nil session[:client_id]
    assert flash[:warning]
    assert_template "client/login"
  end
  
  def test_inactive_login
    #can't login if client is not active
    post :login, :username => "inactive", :password => "test"
    assert_response :success
    assert_nil session[:client_id]
    assert flash[:warning]
    assert_template "client/login"
  end
  
  def test_inactivated_login
    #redirected to activate account
    post :login, :username => "inactivated", :password => "test"
    assert_response :redirect
    assert_nil session[:client_id]
    assert flash[:warning]
    assert_redirected_to :action=>'reactivate'
  end

  def test_login_logoff
    #login
    post :login, :username => "bob", :password => "test"
    assert_response :redirect
    assert session[:client_id]
    #then logoff
    get :logout
    assert_response :redirect
    assert_nil session[:client_id]
    assert_redirected_to :action=>'login'
  end

  def test_forgot_password
    #we can login
    post :login, :username => "bob", :password => "test"
    assert_response :redirect
    assert session[:client_id]
    #logout
    get :logout
    assert_response :redirect
    assert_nil session[:client_id]
    #enter an email that doesn't exist
    post :forgot_password, :username => @bob.username, :email=>"notauser@doesntexist.com"
    assert_response :success
    assert_nil session[:client_id]
    assert flash[:warning]
    assert_template "client/forgot_password"
    #enter a username that doesn't exist
    post :forgot_password, :username => "testtesttest", :email=>"notauser@doesntexist.com"
    assert_response :success
    assert_nil session[:client_id]
    assert flash[:warning]
    assert_template "client/forgot_password"
    #enter bobs email
    post :forgot_password, :username => @bob.username, :email=>@bob.email   
    assert_response :redirect
    assert flash[:message]
    assert_redirected_to :action=>'login'
  end

  def test_login_required
    #can't access account page f not logged in
    get :account
    assert flash[:warning]
    assert_response :redirect
    assert_redirected_to :action=>'login'
    #login
    post :login, :username => "bob", :password => "test"
    assert_response :redirect
    assert session[:client_id]
    #can access it now
    get :account
    assert_response :success
    assert_nil flash[:warning]
    assert_template "client/account"
  end

  def test_change_password
    #can login
    post :login, :username => "bob", :password => "test"
    assert_response :redirect
    assert session[:client_id]
    #try to change password
    #passwords dont match
    post :change_password, :password => "newpass", :password_confirmation => "newpassdoesntmatch"
    assert_response :redirect
    assert flash[:message]
    #empty password
    post :change_password, :password => "", :password_confirmation => ""
    assert_response :redirect
    assert flash[:warning]
    #success - password changed
    post :change_password, :password => "newpass", :password_confirmation => "newpass"
    assert_response :redirect
    assert flash[:message]
    assert_redirected_to :action => 'account'
    #logout
    get :logout
    assert_response :redirect
    assert_nil session[:client_id]
    #old password no longer works
    post :login, :username => @bob.username, :password => "test"
    assert_response :success
    assert_nil session[:client_id]
    assert flash[:warning]
    #new password works
    post :login, :username => @bob.username, :password => "newpass"
    assert_response :redirect
    assert session[:client_id]
  end

  def test_reactivate_email
    #email sent from reactivate page
    #enter an email that doesn't exist
    post :reactivate, :username => @bob.username, :email=>"notauser@doesntexist.com"
    assert_response :success
    assert_nil session[:client_id]
    assert_template "client/reactivate"
    assert flash[:warning]
    #enter a user that doesn't exist
    post :reactivate, :username => "testertesterson", :email=>@bob.email
    assert_response :success
    assert_nil session[:client_id]
    assert_template "client/reactivate"
    assert flash[:warning]
    #enter a user and email that don't match
    post :reactivate, :username => @bob.username, :email=>"test@abc.com"
    assert_response :success
    assert_nil session[:client_id]
    assert_template "client/reactivate"
    assert flash[:warning]
    #enter an activated username and email
    post :reactivate, :username => @bob.username, :email=>@bob.email
    assert_response :redirect
    assert flash[:message]
    assert_redirected_to :action=>'login' 
    #enter inactivated username and email
    post :reactivate, :username => @inactivated.username, :email=>@inactivated.email  
    assert_response :redirect
    assert flash[:message]
    assert_redirected_to :action=>'login'
  end
  
  def test_activation
    get :activate, :activation_code => '1234567890', :client_id => @inactivated.id
    assert_response :redirect
    assert_nil session[:client_id]
    assert flash[:message]
    assert_redirected_to :action=>'login'
  end

  def test_missing_code_activation
    get :activate, :client_id => @inactivated.id
    assert_response :redirect
    assert flash[:warning]
    assert_redirected_to :action => "reactivate"  
  end
  
  def test_missing_code_activation
    get :activate, :activation_code => '1234567890'
    assert_response :redirect
    assert flash[:warning]
    assert_redirected_to :action => "reactivate"   
  end

  def test_invalid_client_id_activation
    get :activate, :activation_code => '1234567890', :client_id => 0
    assert_response :redirect
    assert flash[:warning]
    assert_redirected_to :action=>'login'    
  end
  
  def test_invalid_code_activation
    get :activate, :activation_code => '1111111111', :client_id => @inactivated.id
    assert_response :redirect
    assert flash[:warning]
    assert_redirected_to :action=>'login'    
  end
  
  def test_change_email
    old_email = @bob.email
    #can login
    post :login, :username => "bob", :password => "test"
    assert_response :redirect
    assert session[:client_id]
    #wrong email format
    post :change_email, :email => "badformat"
    assert_response :success
    assert flash[:warning]
    assert_template "client/change_email"
    assert_equal Client.find(@bob.id).email, old_email    
    #success - email changed
    post :change_email, :email => "test@abc.com"
    assert_response :redirect
    assert flash[:message]
    assert_redirected_to :action => 'logout'
    assert_equal Client.find(@bob.id).email, "test@abc.com"
    #can't find old_email
    post :forgot_password, :username => @bob.username, :email=>old_email
    assert_response :success
    assert flash[:warning]
    assert_template "client/forgot_password"
    #can find new email
    post :forgot_password, :username => @bob.username, :email=>"test@abc.com"   
    assert_response :redirect
    assert flash[:message]
    assert_redirected_to :action=>'login'
  end
  
  def test_change_name
    old_name = @bob.name
    #can login
    post :login, :username => "bob", :password => "test"
    assert_response :redirect
    assert session[:client_id]
    #name too long
    post :account, :name => '123456789012345678901234567890123456789012345678900'
    assert_response :success
    assert flash[:warning]
    assert_template "client/account"
    assert_equal Client.find(@bob.id).name, old_name
    #success
    post :account, :name => '1234567890'
    assert_response :success
    assert flash[:message]
    assert_template "client/account"
    assert_equal Client.find(@bob.id).name, '1234567890' 
  end

## unable to test due to @request not getting set in ApplicationController
=begin
  def test_return_to
    #cant access edit without being logged in
    get :edit
    assert flash[:warning]
    assert_response :redirect
    assert_redirected_to :action=>'login'
    assert session[:return_to]
    #login
    post :login, :username => "bob", :password => "test"
    assert_response :redirect
    #redirected to edit
    assert_redirected_to :action=>'edit'
    assert_nil session[:return_to]
    assert session[:client_id]
    assert flash[:message]
    #logout and login again
    get :logout
    assert_nil session[:client_id]
    post :login, :username => "bob", :password => "test"
    assert_response :redirect
    #this time we were redirected to home
    assert_redirected_to :action=>'home'
  end
=end

  # Feats
  def test_create_feat
    self.login
    post :create_feat, :name => 'test'
    assert_response :redirect
    assert flash[:message]
    assert_redirected_to :action => 'badges'
    post :create_feat, :name => 'test', :active => "true"
    assert_response :redirect
    assert flash[:message]
    assert_redirected_to :action => 'badges'
  end
  
  def test_bad_create_feat
    self.login
    post :create_feat
    assert_response :redirect
    assert flash[:error]
    assert_redirected_to :action => 'new_feat'

    post :create_feat, :name => ''
    assert_response :redirect
    assert flash[:error]
    assert_redirected_to :action => 'new_feat'

    post :create_feat, :name => '0123456789012345678901234567890'
    assert_response :redirect
    assert flash[:error]
    assert_redirected_to :action => 'new_feat'
  end
  
  ### TODO - how to test update_feat?
  
  # Badges
  def test_create_badge
    self.login
    post :create_badge, :name => 'test', :description => 'longer test', :badge_image_id => @up.id
    assert_response :redirect
    assert flash[:message]
    assert_redirected_to :action => 'badges'
  end
  
  def test_bad_create_badge
    self.login
    post :create_badge, :description => 'longer test', :badge_image_id => @up.id    
    assert_response :redirect
    assert flash[:error]
    assert_redirected_to :action => 'new_badge' 
    post :create_badge, :name => 'test', :badge_image_id => @up.id    
    assert_response :redirect
    assert flash[:error]
    assert_redirected_to :action => 'new_badge'
    post :create_badge, :name => 'test', :description => 'longer test'   
    assert_response :redirect
    assert flash[:error]
    assert_redirected_to :action => 'new_badge'
    post :create_badge, :name => '0123456789012345678901234567890', :description => 'longer test', :badge_image_id => @up.id
    assert_response :redirect
    assert flash[:error]
    assert_redirected_to :action => 'new_badge'    
  end
       
  def test_create_badge_one_feat
    self.login
    post :create_badge, :name => 'f_test_badge', :description => 'longer test', :badge_image_id => @up.id, 
      :feats => ["#{@burger.id}"], :thresholds => ["10"]
    assert_response :redirect
    assert flash[:message]
    assert_redirected_to :action => 'badges'
    badge = Badge.find(:first, :conditions => {:client_id => @bob.id, :name => 'f_test_badge'})
    assert_equal badge.badges_feats.length, 1
    assert_equal badge.feats[0].name, @burger.name
    assert_equal badge.badges_feats[0].threshold, 10
  end

  def test_bad_create_badge_one_feat
    self.login
    post :create_badge, :name => 'f_test_badge', :description => 'longer test', :badge_image_id => @up.id, 
      :feats => ["#{@burger.id}"], :thresholds => ["0"]
    assert_response :redirect
    assert flash[:error]
    assert_redirected_to :action => 'new_badge'
  end
  
  def test_create_badge_multiple_feats
    self.login
    # create new feat
    self.login
    post :create_feat, :name => 'f_test_feat'
    assert_response :redirect
    assert flash[:message]
    assert_redirected_to :action => 'badges'
    new_feat = Feat.find(:first, :conditions => {:client_id => @bob.id, :name => 'f_test_feat'})
    
    post :create_badge, :name => 'f_test_badge', :description => 'longer test', :badge_image_id => @up.id, 
      :feats => ["#{@burger.id}", "#{new_feat.id}"], :thresholds => ["10","1"]
    assert_response :redirect
    assert flash[:message]
    assert_redirected_to :action => 'badges'
    badge = Badge.find(:first, :conditions => {:client_id => @bob.id, :name => 'f_test_badge'})
    assert_equal badge.badges_feats.length, 2
    badges_feats = BadgesFeat.find(:all, :conditions => {:badge_id => badge.id}, :order => "feat_id ASC")
    assert_equal badges_feats[0].feat_id, @burger.id # first SHOULD always be @burger
    assert_equal badges_feats[0].threshold, 10
    assert_equal badges_feats[1].feat_id, new_feat.id
    assert_equal badges_feats[1].threshold, 1  
  end
  
  ### TODO - how to test updating badges?

end