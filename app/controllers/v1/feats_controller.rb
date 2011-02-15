module V1

  class FeatsController < ApiController

    def log
      if params[:feat_id] && User.verify_params(params)
        # create user - if doesn't already exist
        user = User.lookup_or_create(params)
        # log feat
        feat = UserFeat.new(:user_id => user.id, :client_id => @current_client.id, :feat_id => params[:feat_id])
        if feat.save
          success
        else
          server_error
        end
      else
        bad_request
      end
    end
  
  end
  
end