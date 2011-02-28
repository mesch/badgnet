module V1

  class ApiController < ActionController::Base
    before_filter :login
    after_filter :logout
    respond_to :json, :xml
    
    def login      
      client = Client.find(:first, :conditions => {:id => params[:client_id], :api_key => params[:api_key]})
      if client
        session[:client_id] = client.id
        @current_client = client
        Time.zone = @current_client.time_zone
      else
        unauthorized
      end
    end
    
    def logout
      session[:client_id] = nil
      @current_client = nil
      Time.zone = nil
    end

    # success response
    def success(data=[])
      # 200
      respond_to do |format|
        format.xml { render :xml => [], :status => 400 } # send bad request for xml - for now
        format.json { render :json => data, :status => 200 }
      end
    end
    
    # error cases
    def bad_request(data=[])
      #400 Bad Request - required data not sent
      respond_to do |format|
        format.xml { render :xml => data, :status => 400 }
        format.json { render :json => data, :status => 400 }
      end      
    end
    
    def unauthorized(data=[])
     #401 Unauthorized
     respond_to do |format|
       format.xml { render :xml => data, :status => 401 }
       format.json { render :json => data, :status => 401 }
     end
    end
     
    def server_error(data=[])
      #500 Internal Server Error
      respond_to do |format|
        format.xml { render :xml => data, :status => 500 }
        format.json { render :json => data, :status => 500 }
      end      
    end
  end
  
end