module Admin
  
  class ClientsController < AdminController

    def index

      @limit = params[:limit] || 100
      @id = params[:id] ? params[:id].strip : ""
      @name = params[:name] ? params[:name].strip : ""
      @username = params[:username] ? params[:name].strip : ""
      @show_inactive = params[:show_inactive] ? true : false

      conditions = []
      
      if @name != ""
        conditions << "name = '#{@name}'"
      end
      
      if @username != ""
        conditions << "username = '#{@username}'"
      end
      
      if @id != ""
        if @id == "null" or @id == "nil"
          conditions << "id is null"
        else
          conditions << "id = #{@id}"
        end
      end
      
      if !@show_inactive
        conditions << "active = true"
      end

      @clients = Client.find(:all, :limit => @limit, :conditions => conditions)
    end     

    def multi_update
      # Update multiple clients at the same time      
      unless params[:client_id]
        flash[:error] = "You must select at least one client"
        return redirect_to(admin_clients_url)
      end

      client = Client.find(params[:client_id])
      clients.each { |u| u.update_attributes!(:active => false) }

      flash[:notice] = "Client inactivated."

      redirect_to(:back)
    end

    ### needs work
    def edit
      @client = Client.find(params[:id])
      @client.password = ""
    end

    ### needs work
    def update
      client = Client.find(params[:id])
      new_password = params[:client][:password]

      #if Client.update_attributes(params[:client])
      #  redirect_to(admin_clients_url)
      #else
        flash[:error] = "There was a problem saving the client."
        redirect_to(edit_admin_client_url)
      #end
    end
    
    def new
      @client = Client.new
    end
    
    def create
      client = Client.create(params[:client])
      client.encrypt_password

      if client.save
        redirect_to(admin_clients_url)
      else
        flash[:error] = "There was a problem saving the client."
        redirect_to(new_admin_client_url)
      end
    end
    
  end
  
end