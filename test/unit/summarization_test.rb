require 'test_helper'

# Tests for Client summarization, UserFeat top_feats, UserBadge top_badges
class SummarizationTest < ActiveSupport::TestCase
  self.use_instantiated_fixtures = true
  fixtures :clients
  fixtures :users

  def setup
    # clear all data
    UserBadge.delete_all
    UserFeat.delete_all
    ClientStat.delete_all
    
    @c1 = Client.find(@existingbob.id)
    @c2 = Client.find(@bob.id)
    @u1 = User.find(@kilgore.id)
    @u2 = User.find(@chad.id)
    Time.zone = @c1.time_zone
  end

  def test_one_feat
    UserFeat.create(:user_id => @u1.id, :client_id => @c1.id, :feat_id => @share_trailer.id, :created_at => 1.day.ago)
    start_time = 1.days.ago.beginning_of_day
    end_time = 1.days.ago.end_of_day
    @c1.summarize(start_time, end_time)
    @c2.summarize(start_time, end_time) # using @c1 timezone, but ok for here
    t1 = ClientStat.total_stats(@c1, start_time.to_date, end_time.to_date)
    t2 = ClientStat.total_stats(@c2, start_time.to_date, end_time.to_date)
    assert_equal t1, {:users => 1, :badges => 0, :feats => 1}
    assert_equal t2, {:users => 0, :badges => 0, :feats => 0} 
    
    b1 = UserBadge.top_badges(@c1.id, start_time.to_date, end_time.to_date)
    b2 = UserBadge.top_badges(@c2.id, start_time.to_date, end_time.to_date)
    assert_equal b1.length, 0
    assert_equal b2.length, 0
    
    f1 = UserFeat.top_feats(@c1.id, start_time.to_date, end_time.to_date)
    f2 = UserFeat.top_feats(@c2.id, start_time.to_date, end_time.to_date) # using @c1 timezone, but ok for here    
    assert_equal f1.length, 1
    assert_equal f2.length, 0
    assert_equal f1[0], {:feat_id => @share_trailer.id, :feat_name => @share_trailer.name, :feats => 1}
  end

  def test_before_data
    # should miss
    UserFeat.create(:user_id => @u1.id, :client_id => @c1.id, :feat_id => @share_trailer.id, :created_at => 1.day.ago)
    start_time = 2.days.ago.beginning_of_day
    end_time = 2.days.ago.end_of_day
    @c1.summarize(start_time, end_time)
    t1 = ClientStat.total_stats(@c1, start_time.to_date, end_time.to_date)  
    assert_equal t1, {:users => 0, :badges => 0, :feats => 0}
  end

  def test_after_data
    # should miss
    UserFeat.create(:user_id => @u1.id, :client_id => @c1.id, :feat_id => @share_trailer.id, :created_at => 1.day.ago)
    start_time = 0.days.ago.beginning_of_day
    end_time = 0.days.ago.end_of_day
    @c1.summarize(start_time, end_time)
    t1 = ClientStat.total_stats(@c1, start_time.to_date, end_time.to_date)  
    assert_equal t1, {:users => 0, :badges => 0, :feats => 0}
  end


  def test_multiple_feats
    # also testing day boundaries ...
    UserFeat.create(:user_id => @u1.id, :client_id => @c1.id, :feat_id => @share_trailer.id, :created_at => 1.day.ago.end_of_day)
    UserFeat.create(:user_id => @u1.id, :client_id => @c1.id, :feat_id => @share_trailer.id, :created_at => 1.day.ago.end_of_day)
    UserFeat.create(:user_id => @u1.id, :client_id => @c1.id, :feat_id => @view_trailer.id, :created_at => 1.day.ago.beginning_of_day)
    start_time = 1.days.ago.beginning_of_day
    end_time = 1.days.ago.end_of_day
    @c1.summarize(start_time, end_time)
    t1 = ClientStat.total_stats(@c1, start_time.to_date, end_time.to_date)
    assert_equal t1, {:users => 1, :badges => 0, :feats => 3}
    
    b1 = UserBadge.top_badges(@c1.id, start_time.to_date, end_time.to_date)
    assert_equal b1.length, 0
    
    f1 = UserFeat.top_feats(@c1.id, start_time.to_date, end_time.to_date)   
    assert_equal f1.length, 2
    # also testing sorting
    assert_equal f1[0], {:feat_id => @share_trailer.id, :feat_name => @share_trailer.name, :feats => 2}
    assert_equal f1[1], {:feat_id => @view_trailer.id, :feat_name => @view_trailer.name, :feats => 1}
  end

  def test_multiple_days
    # also testing day boundaries ...
    UserFeat.create(:user_id => @u1.id, :client_id => @c1.id, :feat_id => @share_trailer.id, :created_at => 1.day.ago.end_of_day)
    UserFeat.create(:user_id => @u1.id, :client_id => @c1.id, :feat_id => @share_trailer.id, :created_at => 1.day.ago.beginning_of_day)
    UserFeat.create(:user_id => @u1.id, :client_id => @c1.id, :feat_id => @view_trailer.id, :created_at => Time.zone.now)
    start_time = 1.days.ago.beginning_of_day
    end_time = 0.days.ago.end_of_day
    @c1.summarize(1.days.ago.beginning_of_day, 1.days.ago.end_of_day)
    @c1.summarize(0.days.ago.beginning_of_day, 0.days.ago.end_of_day)    
    t1 = ClientStat.total_stats(@c1, start_time.to_date, end_time.to_date)
    assert_equal t1, {:users => 1, :badges => 0, :feats => 3}
    
    b1 = UserBadge.top_badges(@c1.id, start_time.to_date, end_time.to_date)
    assert_equal b1.length, 0
    
    f1 = UserFeat.top_feats(@c1.id, start_time.to_date, end_time.to_date)   
    assert_equal f1.length, 2
    # also testing sorting
    assert_equal f1[0], {:feat_id => @share_trailer.id, :feat_name => @share_trailer.name, :feats => 2}
    assert_equal f1[1], {:feat_id => @view_trailer.id, :feat_name => @view_trailer.name, :feats => 1}
  end
  
  def test_one_badge
    UserBadge.create(:user_id => @u1.id, :client_id => @c1.id, :badge_id => @beginner.id, :created_at => 1.day.ago.end_of_day)
    start_time = 1.days.ago.beginning_of_day
    end_time = 1.days.ago.end_of_day
    @c1.summarize(start_time, end_time)
    @c2.summarize(start_time, end_time) # using @c1 timezone, but ok for here
    t1 = ClientStat.total_stats(@c1, start_time.to_date, end_time.to_date)
    t2 = ClientStat.total_stats(@c2, start_time.to_date, end_time.to_date)
    assert_equal t1, {:users => 0, :badges => 1, :feats => 0}
    assert_equal t2, {:users => 0, :badges => 0, :feats => 0} 
    
    b1 = UserBadge.top_badges(@c1.id, start_time.to_date, end_time.to_date)
    b2 = UserBadge.top_badges(@c2.id, start_time.to_date, end_time.to_date)
    assert_equal b1.length, 1
    assert_equal b1[0], {:badge_id => @beginner.id, :badge_name => @beginner.name, :badges => 1}
    assert_equal b2.length, 0
    
    f1 = UserFeat.top_feats(@c1.id, start_time.to_date, end_time.to_date)
    f2 = UserFeat.top_feats(@c2.id, start_time.to_date, end_time.to_date) # using @c1 timezone, but ok for here    
    assert_equal f1.length, 0
    assert_equal f2.length, 0
  end


  def test_multiple_badges
    # also testing multiple users ...
    UserBadge.create(:user_id => @u1.id, :client_id => @c1.id, :badge_id => @beginner.id, :created_at => 1.day.ago.end_of_day)
    UserBadge.create(:user_id => @u2.id, :client_id => @c1.id, :badge_id => @beginner.id, :created_at => 1.day.ago.end_of_day)
    UserBadge.create(:user_id => @u1.id, :client_id => @c1.id, :badge_id => @advanced.id, :created_at => 1.day.ago.beginning_of_day)
    start_time = 1.days.ago.beginning_of_day
    end_time = 1.days.ago.end_of_day
    @c1.summarize(start_time, end_time)
    t1 = ClientStat.total_stats(@c1, start_time.to_date, end_time.to_date)
    assert_equal t1, {:users => 0, :badges => 3, :feats => 0}
    
    b1 = UserBadge.top_badges(@c1.id, start_time.to_date, end_time.to_date)
    assert_equal b1.length, 2
    # also testing sorting
    assert_equal b1[0], {:badge_id => @beginner.id, :badge_name => @beginner.name, :badges => 2}
    assert_equal b1[1], {:badge_id => @advanced.id, :badge_name => @advanced.name, :badges => 1}
    
    f1 = UserFeat.top_feats(@c1.id, start_time.to_date, end_time.to_date)   
    assert_equal f1.length, 0
  end

  def test_time_zone
    # should miss (Hawaii vs UTC)
    UserFeat.create(:user_id => @u1.id, :client_id => @c1.id, :feat_id => @share_trailer.id, :created_at => 1.day.ago.beginning_of_day)
    Time.zone = nil
    start_time = 1.days.ago.beginning_of_day
    end_time = 1.days.ago.end_of_day
    @c1.summarize(start_time, end_time)
    t1 = ClientStat.total_stats(@c1, start_time.to_date, end_time.to_date)  
    assert_equal t1, {:users => 0, :badges => 0, :feats => 0}
  end

end
