class ApplicationController < ActionController::Base
  protect_from_forgery

  def login_required
    if session[:client_id]
      @current_client = Client.find(session[:client_id])
      Time.zone = @current_client.time_zone
      return true
    end
    flash[:warning]='Please login to continue.'
    session[:return_to] = request.path
    redirect_to :controller => "client", :action => "login"
    return false 
  end

  def redirect_to_stored
    if return_to = session[:return_to]
      session[:return_to]=nil
      redirect_to(return_to)
    else
      redirect_to :controller=>'client', :action=>'home'
    end
  end
  
  def initialize_client_session(client_id)
    session[:client_id] = client_id
    session[:return_to] = nil
  end
  
  def verify_date(string)
    begin
      return Time.zone.parse(string) ? true : false
    rescue
      return false
    end
  end

end
