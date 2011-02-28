class ClientStat < ActiveRecord::Base
  validates_presence_of :client_id, :day, :users, :user_badges, :user_feats
  validates_uniqueness_of :day, :scope => [:client_id]
  
  attr_protected :id
  
  belongs_to :client

  MAX_CHART_LABELS = 4

  def self.total_stats(client_id, start_date, end_date)
    users = ClientStat.maximum(:users, 
      :conditions => ["client_id = ? AND day BETWEEN ? AND ?", client_id, start_date, end_date])
    users = users ? users : 0
    
    badges = ClientStat.sum(:user_badges,
      :conditions => ["client_id = ? AND day BETWEEN ? AND ?", client_id, start_date, end_date])
    feats =   ClientStat.sum(:user_feats,
        :conditions => ["client_id = ? AND day BETWEEN ? AND ?", client_id, start_date, end_date])
    
    return {:users => users, :badges => badges, :feats => feats}
  end
  
  def self.earliest_day(client_id)
    return ClientStat.minimum(:day, :conditions => ["client_id = ?", client_id])
  end
  
  def self.latest_day(client_id)
    return ClientStat.maximum(:day, :conditions => ["client_id = ?", client_id])
  end
  
  # fill in zero-filled records for missing days
  def self.fill_in_zeros(client_stats, client_id, start_date, end_date)
    # get list of days in stats
    dates = {}
    for client_stat in client_stats
      dates[client_stat.day] = client_stat
    end
    
    p dates
    results = []
    start_date.upto(end_date) {|date|
      p date
      if dates[date]
        results << dates[date]
      else
        results << ClientStat.new(:client_id => client_id, :day => date,
          :users => 0, :user_badges => 0, :user_feats => 0)
      end
    }
    return results
  end

  # method to format for googlecharts
  def self.chart_format(stats)
    badges = []
    feats = []
    days = []
    max_value = 0
    if stats and stats.length > 0
      # only show every few days to fit in the graph
      show = [stats.length/MAX_CHART_LABELS,2].max
      stats.each_with_index {|stat, index|
        if index % show == 0
          days << stat.day.strftime('%m/%d/%y')
        else
          days << ""
        end
        badges << stat.user_badges
        feats << stat.user_feats
      }
      max_value = [feats.max, badges.max].max
    end
    # data needs to be an array for googlecharts
    return {:data => [feats, badges], :axis_labels => [days], :max_value => max_value }
  end
  
end
