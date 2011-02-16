require 'test_helper'

class UserTest < ActiveSupport::TestCase
  self.use_instantiated_fixtures = true
  fixtures :users
  fixtures :clients

  def test_create
    u = User.new(:facebook_id => '1234', :first_name => 'tester', :last_name => 'testerson')
    assert u.save
    
    u = User.new(:facebook_id => '12345')
    assert u.save
  end

  def test_bad_create
    u = User.new(:first_name => 'tester', :last_name => 'testerson')
    assert !u.save
  end

  def test_user_badges_by_client_id
    UserBadge.delete_all
    user = User.find(@kilgore)
    badges = user.user_badges_by_client_id(@bob.id)
    assert_equal badges.length, 0
    # add one for one client
    ub = UserBadge.new(:user_id => @kilgore.id, :client_id => @bob.id, :badge_id => @first.id)
    assert ub.save
    badges = user.user_badges_by_client_id(@bob.id)
    assert_equal badges.length, 1
    # add another for same client
    ub = UserBadge.new(:user_id => @kilgore.id, :client_id => @bob.id, :badge_id => @five.id)
    assert ub.save
    badges = user.user_badges_by_client_id(@bob.id)
    assert_equal badges.length, 2
    # add one for another client
    ub = UserBadge.new(:user_id => @kilgore.id, :client_id => @existingbob.id, :badge_id => @beginner.id)
    assert ub.save
    badges = user.user_badges_by_client_id(@bob.id)
    assert_equal badges.length, 2
    badges = user.user_badges_by_client_id(@existingbob.id)
    assert_equal badges.length, 1
    # add one for another user
    user2 = User.find(@chad)
    ub = UserBadge.new(:user_id => @chad.id, :client_id => @bob.id, :badge_id => @first.id)
    assert ub.save
    badges2 = user2.user_badges_by_client_id(@bob.id)
    assert_equal badges2.length, 1
    badges = user.user_badges_by_client_id(@bob.id)
    assert_equal badges.length, 2
    badges = user.user_badges_by_client_id(@existingbob.id)
    assert_equal badges.length, 1
  end
  
  def test_user_badges_by_client_id_grouped
    UserBadge.delete_all
    user = User.find(@kilgore)
    badges = user.user_badges_by_client_id_grouped(@bob.id)
    assert_equal badges.length, 0
    # add one for one client
    ub = UserBadge.new(:user_id => @kilgore.id, :client_id => @bob.id, :badge_id => @first.id)
    assert ub.save
    badges = user.user_badges_by_client_id_grouped(@bob.id)
    assert_equal badges.length, 1
    assert_equal badges[@first.id], 1
    # add another for same client
    ub = UserBadge.new(:user_id => @kilgore.id, :client_id => @bob.id, :badge_id => @five.id)
    assert ub.save
    badges = user.user_badges_by_client_id_grouped(@bob.id)
    assert_equal badges.length, 2
    assert_equal badges[@first.id], 1
    assert_equal badges[@five.id], 1
    # add one for another client
    ub = UserBadge.new(:user_id => @kilgore.id, :client_id => @existingbob.id, :badge_id => @beginner.id)
    assert ub.save
    badges = user.user_badges_by_client_id_grouped(@bob.id)
    assert_equal badges.length, 2
    assert_equal badges[@first.id], 1
    assert_equal badges[@five.id], 1
    badges = user.user_badges_by_client_id_grouped(@existingbob.id)
    assert_equal badges.length, 1
    assert_equal badges[@beginner.id], 1
    # add one for another user
    user2 = User.find(@chad)
    ub = UserBadge.new(:user_id => @chad.id, :client_id => @bob.id, :badge_id => @first.id)
    assert ub.save
    badges2 = user2.user_badges_by_client_id(@bob.id)
    assert_equal badges2.length, 1
    badges = user.user_badges_by_client_id(@bob.id)
    assert_equal badges.length, 2
    badges = user.user_badges_by_client_id(@existingbob.id)
    assert_equal badges.length, 1
  end

  def test_user_feats_by_client_id
    UserFeat.delete_all
    user = User.find(@kilgore)
    feats = user.user_feats_by_client_id(@existingbob.id)
    assert_equal feats.length, 0
    # add one for one client
    uf = UserFeat.new(:user_id => @kilgore.id, :client_id => @existingbob.id, :feat_id => @view_trailer.id)
    assert uf.save
    feats = user.user_feats_by_client_id(@existingbob.id)
    assert_equal feats.length, 1
    # add same
    uf = UserFeat.new(:user_id => @kilgore.id, :client_id => @existingbob.id, :feat_id => @view_trailer.id)
    assert uf.save
    feats = user.user_feats_by_client_id(@existingbob.id)
    assert_equal feats.length, 2    
    # add another for same client
    uf = UserFeat.new(:user_id => @kilgore.id, :client_id => @existingbob.id, :feat_id => @share_trailer.id)
    assert uf.save
    feats = user.user_feats_by_client_id(@existingbob.id)
    assert_equal feats.length, 3
    # add one for another client
    uf = UserFeat.new(:user_id => @kilgore.id, :client_id => @bob.id, :feat_id => @burger.id)
    assert uf.save
    feats = user.user_feats_by_client_id(@existingbob.id)
    assert_equal feats.length, 3
    feats = user.user_feats_by_client_id(@bob.id)
    assert_equal feats.length, 1
    # add one for another user
    user2 = User.find(@chad)
    uf = UserFeat.new(:user_id => @chad.id, :client_id => @bob.id, :feat_id => @burger.id)
    assert uf.save
    feats2 = user2.user_feats_by_client_id(@bob.id)
    assert_equal feats2.length, 1
    feats = user.user_feats_by_client_id(@existingbob.id)
    assert_equal feats.length, 3
    feats = user.user_feats_by_client_id(@bob.id)
    assert_equal feats.length, 1
  end
  
  def test_user_feats_by_client_id_grouped
    UserFeat.delete_all
    user = User.find(@kilgore)
    feats = user.user_feats_by_client_id_grouped(@existingbob.id)
    assert_equal feats.length, 0
    # add one for one client
    uf = UserFeat.new(:user_id => @kilgore.id, :client_id => @existingbob.id, :feat_id => @view_trailer.id)
    assert uf.save
    feats = user.user_feats_by_client_id_grouped(@existingbob.id)
    assert_equal feats.length, 1
    assert_equal feats[@view_trailer.id], 1
    # add same one
    uf = UserFeat.new(:user_id => @kilgore.id, :client_id => @existingbob.id, :feat_id => @view_trailer.id)
    assert uf.save
    feats = user.user_feats_by_client_id_grouped(@existingbob.id)
    assert_equal feats.length, 1
    assert_equal feats[@view_trailer.id], 2   
    # add another for same client
    uf = UserFeat.new(:user_id => @kilgore.id, :client_id => @existingbob.id, :feat_id => @share_trailer.id)
    assert uf.save
    feats = user.user_feats_by_client_id_grouped(@existingbob.id)
    assert_equal feats.length, 2
    assert_equal feats[@view_trailer.id], 2
    assert_equal feats[@share_trailer.id], 1
    # add one for another client
    uf = UserFeat.new(:user_id => @kilgore.id, :client_id => @bob.id, :feat_id => @burger.id)
    assert uf.save
    feats = user.user_feats_by_client_id_grouped(@existingbob.id)
    assert_equal feats.length, 2
    assert_equal feats[@view_trailer.id], 2
    assert_equal feats[@share_trailer.id], 1
    feats = user.user_feats_by_client_id_grouped(@bob.id)
    assert_equal feats.length, 1
    assert_equal feats[@burger.id], 1
    # add one for another user
    user2 = User.find(@chad)
    uf = UserFeat.new(:user_id => @chad.id, :client_id => @bob.id, :feat_id => @beginner.id)
    assert uf.save
    feats2 = user2.user_feats_by_client_id_grouped(@bob.id)
    assert_equal feats2.length, 1
    feats = user.user_feats_by_client_id_grouped(@existingbob.id)
    assert_equal feats.length, 2
    feats = user.user_feats_by_client_id_grouped(@bob.id)
    assert_equal feats.length, 1
  end

  def test_update_badges
    user = User.find(@kilgore)
    badges = user.user_badges_by_client_id(@existingbob.id)
    badges2 = user.user_badges_by_client_id(@bob.id)
    assert_not_equal badges.length, 0
    assert_not_equal badges2.length, 0    
    # updating shouldn't add anymore
    user.update_badges(@existingbob.id)
    assert_equal badges.length, user.user_badges_by_client_id(@existingbob.id).length
    assert_equal badges2.length, user.user_badges_by_client_id(@bob.id).length
    # deleting a badge with one feat
    UserBadge.delete(@beginner_kilgore.id)
    assert_nil user.user_badges_by_client_id_grouped(@existingbob.id)[@beginner.id]
    assert_equal badges.length, user.user_badges_by_client_id(@existingbob.id).length+1
    assert_equal badges2.length, user.user_badges_by_client_id(@bob.id).length 
    # updating should add it back
    user.update_badges(@existingbob.id)
    assert user.user_badges_by_client_id_grouped(@existingbob.id)[@beginner.id]
    assert_equal badges.length, user.user_badges_by_client_id(@existingbob.id).length    
    assert_equal badges2.length, user.user_badges_by_client_id(@bob.id).length
    # deleting a badge with one feat and threshold > 1
    UserBadge.delete(@advanced_kilgore.id)
    assert_nil user.user_badges_by_client_id_grouped(@existingbob.id)[@advanced.id]
    assert_equal badges.length, user.user_badges_by_client_id(@existingbob.id).length+1
    assert_equal badges2.length, user.user_badges_by_client_id(@bob.id).length
    # updating should add it back
    user.update_badges(@existingbob.id)
    assert user.user_badges_by_client_id_grouped(@existingbob.id)[@advanced.id]
    assert_equal badges.length, user.user_badges_by_client_id(@existingbob.id).length    
    assert_equal badges2.length, user.user_badges_by_client_id(@bob.id).length
    # deleting a badge with multiple feats
    UserBadge.delete(@expert_kilgore.id)
    assert_nil user.user_badges_by_client_id_grouped(@existingbob.id)[@expert.id]
    assert_equal badges.length, user.user_badges_by_client_id(@existingbob.id).length+1
    assert_equal badges2.length, user.user_badges_by_client_id(@bob.id).length
    # updating should add it back
    user.update_badges(@existingbob.id)
    assert user.user_badges_by_client_id_grouped(@existingbob.id)[@expert.id]
    assert_equal badges.length, user.user_badges_by_client_id(@existingbob.id).length    
    assert_equal badges2.length, user.user_badges_by_client_id(@bob.id).length
  end

end
