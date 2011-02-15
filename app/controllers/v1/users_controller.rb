module V1

  class UsersController < ApiController

    def badges
      if User.verify_params(params)
        user = User.lookup(params)
        # update user's badges - here for now
        if user.update_badges(@current_client.id)      
          success(user.user_badges_by_client_id(@current_client.id))
        else
          server_error
        end
      else
        bad_request
      end
    end
    
    def feats
      if User.verify_params(params)
        user = User.lookup(params)
        success(user.user_feats_by_client_id(@current_client.id))
      else
        bad_request
      end   
    end
   
  end
  
end