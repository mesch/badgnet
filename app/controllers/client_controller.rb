class ClientController < ApplicationController
  before_filter :login_required, :except => [:signup, :change_password, :login, :logout]

  def home
    
  end

  def signup
    @client = Client.new(params[:client])
    if request.post?  
      if @client.save
        c = Client.authenticate(@client.username, @client.password)
        session[:client_id] = c.nil? ? nil : c.id
        flash[:message] = "Signup successful."
        redirect_to :action => "home"          
      else
        flash[:warning] = "Signup unsuccessful."
      end
    end
  end

  def login
    @client = Client.new(params[:client])
    if request.post?
      c = Client.authenticate(params[:client][:username], params[:client][:password])
      session[:client_id] = c.nil? ? nil : c.id
      if session[:client_id]
        flash[:message]  = "Login successful."
        redirect_to_stored
      else
        flash[:warning] = "Login unsuccessful."
      end
    end
  end

  def logout
    session[:client_id] = nil
    flash[:message] = 'Logged out.'
    redirect_to :action => 'login'
  end

  def forgot_password
    if request.post?
      c = Client.find_by_email(params[:client][:email])
      if c and c.send_new_password
        flash[:message]  = "A new password has been sent by email."
        redirect_to :action=>'login'
      else
        flash[:warning]  = "Couldn't send password."
      end
    end
  end

  def change_password
    client_id = session[:client_id]
    @client = Client.find(client_id)
    if request.post?
      if params[:client][:password].blank?
        flash[:warning] = "Passwords cannot be empty."
        redirect_to :controller => 'client', :action => 'change_password'
      else
        @client.update_attributes(:password => params[:client][:password], :password_confirmation => params[:client][:password_confirmation])
        if @client.save
          flash[:message] = "Password changed."
          redirect_to :controller => 'client', :action => 'edit'
        else
          flash[:warning] = "Password not changed. Passwords must be at least 5 characters and match the confirmation field."
          redirect_to :controller => 'client', :action => 'change_password'
        end
      end
    end
  end

end