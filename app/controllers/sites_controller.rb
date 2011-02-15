class SitesController < ActionController::Base
  def home
    redirect_to :controller => :client, :action => :login
  end
  
end