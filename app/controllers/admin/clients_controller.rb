module Admin
  
  class ClientsController < AdminController

    def index

      @limit = params[:limit] || 100
      @id = params[:id] ? params[:id].strip : ""
      @name = params[:name] ? params[:name].strip : ""
      @username = params[:username] ? params[:username].strip : ""
      @show_inactive = params[:show_inactive] ? true : false

      conditions = {}
      
      if @name != ""
        conditions[:name] = @name  
      end
      
      if @username != ""
        conditions[:username] = @username
      end
      
      if @id != ""
        conditions[:id] = @id
      end
      
      if !@show_inactive
        conditions[:active] = true
      end

      @clients = Client.find(:all, :limit => @limit, :conditions => conditions)
    end     

    def multi_update
      # Update multiple clients at the same time      
      unless params[:client_id]
        flash[:error] = "You must select at least one client"
        return redirect_to(admin_clients_url)
      end
      
      clients = Client.find(params[:client_id])
      if params['activate']  
        clients.each { |c| c.update_attribute(:active, true) }
      end
      
      if params['inactivate']  
        clients.each { |c| c.update_attribute(:active, false) }
      end      
      
      flash[:notice] = "Clients updated."

      redirect_to(:back)
    end
    
  end
  
end