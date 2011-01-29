require 'test_helper'
require 'client_controller'

# Re-raise errors caught by the controller.
class ClientController; def rescue_action(e) raise e end; end

class ClientControllerTest < ActionController::TestCase

  self.use_instantiated_fixtures  = true

  fixtures :clients

  def setup
    @controller = ClientController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "localhost"
  end

  def test_auth_bob
    #check we can login
    post :login, :client => { :username => "bob", :password => "test" }
    assert session[:client_id]
    assert_equal @bob, Client.find(session[:client_id])
    assert_response :redirect
    assert_redirected_to :action=>'home'
    p request.path
    p request.fullpath
    p @request.path
    p @request.fullpath
  end

  def test_signup
    #check we can signup and then login
    post :signup, :client => { :username => "newbob", :password => "newpassword", :password_confirmation => "newpassword", :email => "newbob@mcbob.com" }
    assert_response :redirect
    assert_not_nil session[:client_id]
    assert session[:client_id]
    assert_redirected_to :action=>'home'
  end

  def test_bad_signup
    #check we can't signup without all required fields
    post :signup, :client => { :username => "newbob", :password => "newpassword", :password_confirmation => "wrong" , :email => "newbob@mcbob.com"}
    assert_response :success
    assert_template "client/signup"
    assert_nil session[:client_id]

    post :signup, :client => { :username => "yo", :password => "newpassword", :password_confirmation => "newpassword" , :email => "newbob@mcbob.com"}
    assert_response :success
    assert_template "client/signup"
    assert_nil session[:client_id]

    post :signup, :client => { :username => "yo", :password => "newpassword", :password_confirmation => "wrong" , :email => "newbob@mcbob.com"}
    assert_response :success
    assert_template "client/signup"
    assert_nil session[:client_id]
  end

  def test_invalid_login
    #can't login with incorrect password
    post :login, :client=> { :username => "bob", :password => "not_correct" }
    assert_response :success
    assert_nil session[:client_id]
    assert flash[:warning]
    assert_template "client/login"
  end

  def test_login_logoff
    #login
    post :login, :client=>{ :username => "bob", :password => "test"}
    assert_response :redirect
    assert session[:client_id]
    #then logoff
    get :logout
    assert_response :redirect
    assert_nil session[:client_id]
    assert_redirected_to :action=>'login'
  end

=begin
  def test_forgot_password
    #we can login
    post :username, :client=>{ :username => "bob", :password => "test"}
    assert_response :redirect
    assert session[:client_id]
    #logout
    get :logout
    assert_response :redirect
    assert_nil session[:client_id]
    #enter an email that doesn't exist
    post :forgot_password, :client => {:email=>"notauser@doesntexist.com"}
    assert_response :success
    assert_nil session[:client_id]
    assert_template "client/forgot_password"
    assert flash[:warning]
    #enter bobs email
    post :forgot_password, :client => {:email=>"exbob@mcbob.com"}   
    assert_response :redirect
    assert flash[:message]
    assert_redirected_to :action=>'login'
  end
=end

  def test_login_required
    #can't access welcome if not logged in
    get :home
    assert flash[:warning]
    assert_response :redirect
    assert_redirected_to :action=>'login'
    #login
    post :login, :client=>{ :username => "bob", :password => "test"}
    assert_response :redirect
    assert session[:client_id]
    #can access it now
    get :home
    assert_response :success
    assert_nil flash[:warning]
    assert_template "client/home"
  end

  def test_change_password
    #can login
    post :login, :client=>{ :username => "bob", :password => "test"}
    assert_response :redirect
    assert session[:client_id]
    #try to change password
    #passwords dont match
    post :change_password, :client=>{ :password => "newpass", :password_confirmation => "newpassdoesntmatch"}
    assert_response :redirect
    assert flash[:message]
    client = Client.find(session[:client_id])
    #empty password
    post :change_password, :client=>{ :password => "", :password_confirmation => ""}
    assert_response :redirect
    assert flash[:warning]
    client = Client.find(session[:client_id])  
    #success - password changed
    post :change_password, :client=>{ :password => "newpass", :password_confirmation => "newpass"}
    assert_response :redirect
    assert flash[:message]
    client = Client.find(session[:client_id])
    assert_redirected_to :action => 'edit'
    #logout
    get :logout
    assert_response :redirect
    assert_nil session[:client_id]
    #old password no longer works
    post :login, :client=> { :username => "bob", :password => "test" }
    assert_response :success
    assert_nil session[:client_id]
    assert flash[:warning]
    #new password works
    post :login, :client=>{ :username => "bob", :password => "newpass"}
    assert_response :redirect
    assert session[:client_id]
  end

## unable to test?
=begin
  def test_return_to
    #cant access edit without being logged in
    get :edit
    assert flash[:warning]
    assert_response :redirect
    assert_redirected_to :action=>'login'
    assert session[:return_to]
    p session[:return_to]
    #login
    post :login, :client=>{ :username => "bob", :password => "test"}
    assert_response :redirect
    #redirected to edit
    assert_redirected_to :action=>'edit'
    assert_nil session[:return_to]
    assert session[:client_id]
    assert flash[:message]
    #logout and login again
    get :logout
    assert_nil session[:client_id]
    post :login, :client=>{ :username => "bob", :password => "test"}
    assert_response :redirect
    #this time we were redirected to home
    assert_redirected_to :action=>'home'
  end
=end

end