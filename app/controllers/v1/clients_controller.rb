module V1

  class ClientsController < ApiController

    def badges
      success(@current_client.active_badges)
    end
    
    def feats
      success(@current_client.active_feats)    
    end
   
  end
  
end