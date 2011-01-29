class ApplicationController < ActionController::Base
  protect_from_forgery

  def login_required
    if session[:client_id]
      return true
    end
    flash[:warning]='Please login to continue.'
    p request.path
    p request.fullpath
    session[:return_to] = request.path
    p session[:return_to]
    redirect_to :controller => "client", :action => "login"
    return false 
  end

  def current_client
    client_id = session[:client_id]
    return Client.find(client_id)
  end

  def redirect_to_stored
    if return_to = session[:return_to]
      session[:return_to]=nil
      redirect_to(return_to)
    else
      redirect_to :controller=>'client', :action=>'home'
    end
  end

end
