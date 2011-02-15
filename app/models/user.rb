class User < ActiveRecord::Base
  validates_presence_of :facebook_id
  
  has_many :user_badges
  has_many :user_feats

  def full_name
    return "#{self.first_name} #{self.last_name}"
  end

  def self.verify_params(params)
    # just by facebook_id for now
    if params[:facebook_id]
      return true
    else
      return false
    end
  end

  def self.lookup(params)
    return User.find_by_facebook_id(params[:facebook_id])
  end
    
  def self.lookup_or_create(params)
    # create user - if not already there
    return User.find_or_create_by_facebook_id(params[:facebook_id])
  end

  def user_badges_by_client_id(client_id)
    return UserBadge.find(:all, :joins => :user, 
      :conditions => ["users.id = ? AND user_badges.client_id = ?", self.id, client_id])    
  end

  def user_badges_by_client_id_grouped(client_id)
    return UserBadge.count(:all, 
      :joins => :user, 
      :conditions => ["users.id = ? AND user_badges.client_id = ?", self.id, client_id],
      :group => "user_badges.badge_id")
  end

  def user_feats_by_client_id(client_id)
    return UserFeat.find(:all, :joins => :user, 
      :conditions => ["users.id = ? AND user_feats.client_id = ?", self.id, client_id])    
  end
  
  def user_feats_by_client_id_grouped(client_id)
    return UserFeat.count(:all, 
      :joins => :user, 
      :conditions => ["users.id = ? AND user_feats.client_id = ?", self.id, client_id],
      :group => "user_feats.feat_id")
  end

  def update_badges(client_id)
    # Get the client's badges
    client_badges = Client.find(client_id).active_badges
    # Get the count of the user's badges by badge_id
    user_badges = self.user_badges_by_client_id_grouped(client_id)
    # Get the count of the user's feats by feat_id
    user_feats = self.user_feats_by_client_id_grouped(client_id)
    for client_badge in client_badges
      unless user_badges[client_badge.id]
        # go through each badge_feat to see if we can add the badge
        for badge_feat in client_badge.badges_feats
          if badge_feat.threshold > user_feats[badge_feat.feat_id]
            break
          end
        end
        # create a user_badge
        user_badge = UserBadge.new(:user_id => self.id, :client_id => client_id, :badge_id => client_badge.id)
        unless user_badge.save
          return false
        end
      end
    end
    return true
  end

end
