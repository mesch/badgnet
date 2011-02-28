require 'test_helper'

class ClientStatTest < ActiveSupport::TestCase
  self.use_instantiated_fixtures = true
  fixtures :clients

  def setup
    ClientStat.delete_all
    Time.zone = @bob.time_zone
    @days = []
    for day in 20.days.ago.to_date..1.days.ago.to_date
      @days << day
    end
  end

  def test_create
    r = ClientStat.new(:client_id => @bob.id, :day => @days[0], :users => 10, :user_badges => 6, :user_feats => 12)
    assert r.save
  end
  
  def test_create_bad
    r = ClientStat.new(:day => @days[0], :users => 10, :user_badges => 6, :user_feats => 12)
    assert !r.save
    r = ClientStat.new(:client_id => @bob.id, :users => 10, :user_badges => 6, :user_feats => 12)
    assert !r.save
    r = ClientStat.new(:client_id => @bob.id, :day => @days[0], :user_badges => 6, :user_feats => 12)
    assert !r.save
    r = ClientStat.new(:client_id => @bob.id, :day => @days[0], :users => 10, :user_feats => 12)
    assert !r.save
    r = ClientStat.new(:client_id => @bob.id, :day => @days[0], :users => 10, :user_badges => 6)
    assert !r.save    
  end
  
  def test_create_zeros
    r = ClientStat.new(:client_id => @bob.id, :day => @days[0], :users => 0, :user_badges => 0, :user_feats => 0)
    assert r.save
  end    
  
  def test_total
    ClientStat.create(:client_id => @bob.id, :day => @days[0], :users => 2, :user_badges => 1, :user_feats => 3)
    ClientStat.create(:client_id => @bob.id, :day => @days[1], :users => 4, :user_badges => 2, :user_feats => 6)
    total_stats = ClientStat.total_stats(@bob.id, @days[0], @days[1])
    assert_equal total_stats, {:users => 4, :badges => 3, :feats => 9}
  end
  
  def test_total_partial_hit
    ClientStat.create(:client_id => @bob.id, :day => @days[0], :users => 2, :user_badges => 1, :user_feats => 3)
    ClientStat.create(:client_id => @bob.id, :day => @days[1], :users => 4, :user_badges => 2, :user_feats => 6)
    total_stats = ClientStat.total_stats(@bob.id, @days[0], @days[0])
    assert_equal total_stats, {:users => 2, :badges => 1, :feats => 3}
    total_stats = ClientStat.total_stats(@bob.id, @days[1], @days[1])
    assert_equal total_stats, {:users => 4, :badges => 2, :feats => 6}      
  end
  
  def test_total_miss
    ClientStat.create(:client_id => @bob.id, :day => @days[1], :users => 4, :user_badges => 2, :user_feats => 6)
    total_stats = ClientStat.total_stats(@bob.id, @days[0], @days[0])
    assert_equal total_stats, {:users => 0, :badges => 0, :feats => 0}
    total_stats = ClientStat.total_stats(@bob.id, @days[2], @days[1])
    assert_equal total_stats, {:users => 0, :badges => 0, :feats => 0}      
  end
  
  def test_total_no_data
    total_stats = ClientStat.total_stats(@bob.id, @days[0], @days[0])
    assert_equal total_stats, {:users => 0, :badges => 0, :feats => 0}    
  end
  
  def test_earliest_day
    # no data
    assert_nil ClientStat.earliest_day(@bob.id)
    # insert data
    ClientStat.create(:client_id => @bob.id, :day => @days[0], :users => 2, :user_badges => 1, :user_feats => 3)
    ClientStat.create(:client_id => @bob.id, :day => @days[1], :users => 4, :user_badges => 2, :user_feats => 6)
    assert_equal ClientStat.earliest_day(@bob.id), @days[0]
    # try inserting reverse order
    ClientStat.delete_all
    ClientStat.create(:client_id => @bob.id, :day => @days[1], :users => 2, :user_badges => 1, :user_feats => 3)
    ClientStat.create(:client_id => @bob.id, :day => @days[0], :users => 4, :user_badges => 2, :user_feats => 6)
    assert_equal ClientStat.earliest_day(@bob.id), @days[0]        
  end
  
  def test_latest_day
    # no data
    assert_nil ClientStat.latest_day(@bob.id)
    # insert data
    ClientStat.create(:client_id => @bob.id, :day => @days[0], :users => 2, :user_badges => 1, :user_feats => 3)
    ClientStat.create(:client_id => @bob.id, :day => @days[1], :users => 4, :user_badges => 2, :user_feats => 6)
    assert_equal ClientStat.latest_day(@bob.id), @days[1]
    # try inserting reverse order
    ClientStat.delete_all
    ClientStat.create(:client_id => @bob.id, :day => @days[1], :users => 2, :user_badges => 1, :user_feats => 3)
    ClientStat.create(:client_id => @bob.id, :day => @days[0], :users => 4, :user_badges => 2, :user_feats => 6)
    assert_equal ClientStat.latest_day(@bob.id), @days[1]    
  end

  def test_chart_format_no_data
    assert_equal ClientStat.chart_format(nil), {:data => [[], []], :axis_labels => [[]], :max_value => 0 }
    assert_equal ClientStat.chart_format([]), {:data => [[], []], :axis_labels => [[]], :max_value => 0 }
    # just no data
    stats = ClientStat.where(:client_id => @bob.id, :day => @days.min..@days.max)
    assert_equal ClientStat.chart_format(stats), {:data => [[], []], :axis_labels => [[]], :max_value => 0 }
  end

  def test_chart_format_max_val_feats
    # insert data (max value in feats)
    @days.each {|date|
      if date == @days[0]
        # for max value 
        ClientStat.create(:client_id => @bob.id, :day => date, :users => 2, :user_badges => 1, :user_feats => 4)
      else
        ClientStat.create(:client_id => @bob.id, :day => date, :users => 2, :user_badges => 1, :user_feats => 3)
      end
    }
    stats = ClientStat.where(:client_id => @bob.id, :day => @days[0]..@days[19])
    chart_stats = ClientStat.chart_format(stats)
    assert_equal chart_stats[:data][0].length, 20
    assert_equal chart_stats[:data][0].sum, 61
    assert_equal chart_stats[:data][1].length, 20
    assert_equal chart_stats[:data][1].sum, 20    
    assert_equal chart_stats[:max_value], 4
  end
  
  def test_chart_format_max_val_badges
    # insert data (max value in badges)
    @days.each {|date|
      if date == @days[0]
        # for max value
        ClientStat.create(:client_id => @bob.id, :day => date, :users => 2, :user_badges => 4, :user_feats => 3)
      else
        ClientStat.create(:client_id => @bob.id, :day => date, :users => 2, :user_badges => 1, :user_feats => 3)
      end
    }
    stats = ClientStat.where(:client_id => @bob.id, :day => @days[0]..@days[19])
    chart_stats = ClientStat.chart_format(stats)
    assert_equal chart_stats[:data][0].length, 20
    assert_equal chart_stats[:data][0].sum, 60
    assert_equal chart_stats[:data][1].length, 20
    assert_equal chart_stats[:data][1].sum, 23   
    assert_equal chart_stats[:max_value], 4
  end
  
  def test_chart_format_max_val_users   
    # insert data (max value in users)
    @days.each {|date|
      if date == @days[0]
        # for max value
        ClientStat.create(:client_id => @bob.id, :day => date, :users => 4, :user_badges => 1, :user_feats => 3)
      else
        ClientStat.create(:client_id => @bob.id, :day => date, :users => 2, :user_badges => 1, :user_feats => 3)
      end
    }
    stats = ClientStat.where(:client_id => @bob.id, :day => @days[0]..@days[19])
    chart_stats = ClientStat.chart_format(stats)
    assert_equal chart_stats[:data][0].length, 20
    assert_equal chart_stats[:data][0].sum, 60
    assert_equal chart_stats[:data][1].length, 20
    assert_equal chart_stats[:data][1].sum, 20    
    assert_equal chart_stats[:max_value], 3
  end

  def test_chart_format_axis_labels
    start_date = @days.min
    end_date = @days.max
    # insert data
    @days.each {|date|
        ClientStat.create(:client_id => @bob.id, :day => date, :users => 2, :user_badges => 1, :user_feats => 3)
    }
    stats = ClientStat.where(:client_id => @bob.id, :day => @days[0]..@days[19]) # 20 days
    chart_stats = ClientStat.chart_format(stats)
    assert_equal num_dates(chart_stats[:axis_labels][0]), 4
    stats = ClientStat.where(:client_id => @bob.id, :day => @days[0]..@days[6]) # 7 days
    chart_stats = ClientStat.chart_format(stats)
    assert_equal num_dates(chart_stats[:axis_labels][0]), 4
    stats = ClientStat.where(:client_id => @bob.id, :day => @days[0]..@days[5]) # 6 days
    chart_stats = ClientStat.chart_format(stats)
    assert_equal num_dates(chart_stats[:axis_labels][0]), 3
    stats = ClientStat.where(:client_id => @bob.id, :day => @days[0]..@days[4]) # 5 days
    chart_stats = ClientStat.chart_format(stats)
    assert_equal num_dates(chart_stats[:axis_labels][0]), 3    
    
  end
  
private
  
  def num_dates(axis_labels)
    count = 0
    axis_labels.each { |label|
      unless label == ""
        count += 1
      end
    }
    return count
  end

end
