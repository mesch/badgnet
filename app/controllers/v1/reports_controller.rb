require 'date_helper'

module V1

  class ReportsController < ApiController

    # general params:
    # client_id: [client_id]
    # api_key: [api_key]
    # start_day: (inclusive day in client's timezone with form 'MM/DD/YYYY' or 'DD-MM-YYYY in EU terms)
    # end_day: (inclusive day in client's timezone with form 'MM/DD/YYYY' or 'DD-MM-YYYY in EU terms)
    # summation: 'total' or 'daily' - defaults to 'total' (only for client() method)

    # returns
    # [start_day, end_day, badges, feats]
    def client
      if (params[:start_day] && params[:end_day])
        summation = params[:summation] == 'daily' ? 'daily' : 'total'
        start_date = Time.zone.parse(params[:start_day]).to_date
        end_date = Time.zone.parse(params[:end_day]).to_date
        data = []
        if summation == 'daily'
          stats = ClientStat.find(:all, 
            :conditions => {:client_id => @current_client.id, :day => start_date..end_date},
            :order => "day asc")
          for client_stat in client_stats
            data << [client_stat.day, client_stat.day,
              client_stat.user_badges, client_stat.user_feats]
          end
        else
          stats = ClientStat.total_stats(@current_client.id, start_date, end_date)
          data << [DateHelper.format(start_date), DateHelper.format(end_date),
            stats[:badges], stats[:feats]]
        end 
        success(data)
      else
        bad_request()
      end
    end

    ### TODO: needs work (formating of data, limit, pass in badge_id?)
    # returns
    # [
    #  [ start_day, end_day, badge_id, badge_name, badges ]
    #  ...
    # ]  
    def badges
      if (params[:start_day] && params[:end_day])
        start_date = Time.zone.parse(params[:start_day]).to_date
        end_date = Time.zone.parse(params[:end_day]).to_date
        data = UserBadge.top_badges(@current_client.id, start_date, end_date)
        success(data)
      else
        bad_request()
      end
    end
    
    ### TODO: needs work (formating of data, limit, pass in feat_id?)
    # returns
    # [
    #  [ start_day, end_day, feat_id, feat_name, feats ]
    #  ...
    # ]    
    def feats
      if (params[:start_day] && params[:end_day])
        start_date = Time.zone.parse(params[:start_day]).to_date
        end_date = Time.zone.parse(params[:end_day]).to_date
        data = UserFeat.top_feats(@current_client.id, start_date, end_date)
        success(data)
      else
        bad_request()
      end  
    end
   
  end
  
end