class ClientController < ApplicationController
  before_filter :login_required, :except => [:signup, :forgot_password, :activate, :reactivate, :login, :logout]

  # Use the client layout
  layout "client"

  # Badge methods
  def badges
    @badges = Badge.find(:all, 
      :conditions => {:client_id => @current_client.id }, 
      :order => 'active desc, created_at desc')
    @feats = Feat.find(:all, 
      :conditions => {:client_id => @current_client.id },
      :order => 'active desc, created_at desc')
    @image_rows = BadgeImage.find(:all, 
      :conditions => {:client_id => @current_client.id },
      :order => 'active desc, created_at desc ').in_groups_of(4, false)
  end

  def new_badge
    @badge = Badge.new
    
    group_count = 10
    
    @official_images = BadgeImage.find(:all, 
      :conditions => {:client_id => nil, :active => true}).in_groups_of(group_count, false)
    @selected_image = { @official_images[0][0].id => "selected" }
    @badge.badge_image_id = @official_images[0][0].id 
    @client_images = BadgeImage.find(:all, 
      :conditions => {:client_id => @current_client.id, :active => true}).in_groups_of(group_count, false)

    @client_feats = Feat.find(:all, :conditions => {:client_id => @current_client.id, :active => true })      
    @feats = []
    render :badge_form
  end

  def create_badge    
    begin
      Badge.transaction do
        # Create Badge
        active = params[:active].nil? ? false : params[:active]
        badge = Badge.new(:name => params[:name], :description => params[:description],
          :badge_image_id => params[:badge_image_id], :active => active,
          :client_id => @current_client.id)
        badge.save!
        # Create each BadgesFeat
        feats = params[:feats]
        thresholds = params[:thresholds]
        unless feats.nil?
          for i in (0..feats.length-1)
            bf = BadgesFeat.new(:badge_id => badge.id, :feat_id => feats[i], :threshold => thresholds[i])
            bf.save!
          end
        end
      end
      flash[:message] = "Your badge was created successfully."
      redirect_to :action => :badges
    rescue ActiveRecord::RecordInvalid => invalid
      ### TODO: add invalid.record.errors?
      flash[:error] = "There was a problem creating your badge."
      redirect_to :action => :new_badge     
    end
  end

  def edit_badge
    @badge = Badge.find(params[:id])
    
    group_count = 10
    
    @official_images = BadgeImage.find(:all, 
      :conditions => {:client_id => nil, :active => true}).in_groups_of(group_count, false)
    @selected_image = { @badge.badge_image_id => "selected" }
    @client_images = BadgeImage.find(:all, 
      :conditions => {:client_id => @current_client.id, :active => true}).in_groups_of(group_count, false)
    
    @client_feats = Feat.find(:all, :conditions => {:client_id => @current_client.id, :active => true })
    @feats = @badge.badges_feats(:include => :feat)
    render :badge_form
  end

  def update_badge
    badge = Badge.find(params[:id])
    begin
      Badge.transaction do
        # Update badge
        active = params[:active].nil? ? false : params[:active]
        badge.update_attributes!(:name => params[:name], :description => params[:description],
          :badge_image_id => params[:badge_image_id], :active => active, 
          :client_id => @current_client.id)
        # Delete all current feats
        BadgesFeat.delete_all(:badge_id => badge.id)
        # Create each BadgesFeat
        feats = params[:feats]
        thresholds = params[:thresholds]
        unless feats.nil?
          for i in (0..feats.length-1)
            bf = BadgesFeat.new(:badge_id => badge.id, :feat_id => feats[i], :threshold => thresholds[i])
            bf.save!
          end
        end
      end
      flash[:message] = "Your badge was updated successfully."
      redirect_to :action => :badges
    rescue ActiveRecord::RecordInvalid => invalid
      ### TODO: add invalid.record.errors?
      flash[:error] = "There was a problem updating your badge."
      redirect_to :action => :edit_badge
    end
  end
  
  # Feat methods
  def new_feat
    @feat = Feat.new()
    render :feat_form
  end

  def create_feat
    begin
      active = active = params[:active].nil? ? false : params[:active]
      feat = Feat.create(:name => params[:name], :active => active, :client_id => @current_client.id)
      feat.save!
      flash[:message] = "Your feat was created successfully."
      redirect_to :action => :badges
    rescue ActiveRecord::RecordInvalid => invalid
      ### TODO: add invalid.record.errors?
      flash[:error] = "There was a problem creating your feat."
      redirect_to :action => :new_feat
    end
  end

  def edit_feat
    @feat = Feat.find(params[:id])
    render :feat_form
  end

  def update_feat
    feat = Feat.find(params[:id])
    begin
      active = params[:active].nil? ? false : params[:active]
      feat.update_attributes!(:name => params[:name], :active => active, :client_id => @current_client.id)
      feat.save!
      flash[:message] = "Your feat was updated successfully."
      redirect_to :action => :badges
    rescue ActiveRecord::RecordInvalid => invalid
      ### TODO: add invalid.record.errors?
      flash[:error] = "There was a problem updating your feat."
      redirect_to :action => :edit_feat 
    end
  end
  
  # BadgeImage methods
  def images
    @images = BadgeImage.find(:all, :conditions => {:client_id => @current_client.id, :active => true })
  end

  def images_submit    
    bi = BadgeImage.create(:image => params[:badge_image], :client_id => @current_client.id)

    if bi.errors.empty?
      @result = { :result => "success", :message => "Image succesfully uploaded!", :url => bi.image(:thumb) }
    else
      @result = { :result => "error", :message => bi.errors.full_messages.join(", ")}
    end
    render :layout => false
  end

  # Account methods
  ### TODO - add a real home page
  def home
    redirect_to :action => :badges
  end
  
  def account
    @client = Client.find(@current_client.id)
    if request.post?
      if params[:name]
        if @client.update_attributes(:name => params[:name])
          flash[:message] = "Your account has been updated."
        else
          flash[:warning] = "Could not update account. Please try again."
        end
      end
    end
  end

  def signup    
    @client = Client.new()
    if request.post?
      c = Client.new(:name => params[:name], :username => params[:username], 
        :password => params[:password], :password_confirmation => params[:password_confirmation],
        :email => params[:email])
      # Captcha validation
      unless verify_recaptcha(:private_key => OPTIONS[:recaptcha_private_key])      
        flash[:warning] = "Invalid captcha results. Please try again."
        render(:action => :signup)
        return
      end
      if c.save and c.send_activation()
          flash[:message] = "Signup successful. An activation code has been sent by email."
          redirect_to :action =>'login'
      else
        flash[:warning] = "Signup unsuccessful."
      end
    end
  end

  def login
    @client = Client.new()
    if request.post?
      c = Client.authenticate(params[:username], params[:password])
      if c.nil?
        flash[:warning] = "Login unsuccessful."
      else
        if c.active
          if c.activated        
            session[:client_id] = c.id
            flash[:message]  = "Login successful."
            redirect_to_stored
          else
            flash[:warning] = "You must activate your account."
            redirect_to :action => :reactivate
          end
        else
          flash[:warning] = "Your account is no longer active. Please contact customer support."
        end
      end
    end
  end

  def logout
    session[:client_id] = nil
    flash[:message] = 'Logged out.'
    redirect_to :action => 'login'
  end

  def forgot_password
    if request.post?
      c = Client.find(:first, :conditions => {:username => params[:username], :email => params[:email]})
      if c and c.send_new_password
        flash[:message]  = "A new password has been sent by email."
        redirect_to :action =>'login'
      else
        flash[:warning]  = "Could not find your account. Please enter a valid username and email."
      end
    end
  end

  def change_password
    @client = Client.find(@current_client.id)
    if request.post?
      if params[:password].blank?
        flash[:warning] = "Passwords cannot be empty."
        redirect_to :controller => 'client', :action => 'change_password'
      else
        @client.update_attributes(:password => params[:password], :password_confirmation => params[:password_confirmation])
        if @client.save
          flash[:message] = "Password changed."
          redirect_to :controller => 'client', :action => 'account'
        else
          flash[:warning] = "Password not changed. Passwords must be at least 3 characters and match the confirmation field."
          redirect_to :controller => 'client', :action => 'change_password'
        end
      end
    end
  end
  
  def change_email
    @client = Client.find(@current_client.id)
    if request.post?
      if @client.update_email(params[:email])
        flash[:message]  = "Your email has been updated."
        redirect_to :action => 'logout'
      else
        flash[:warning]  = "Could not update email. Please try again."
      end
    end
  end
  
  def activate
    if params[:activation_code].blank? or params[:client_id].blank?
      flash[:warning] = "The activation code was missing.  Please follow the URL from your email."
      redirect_to :action => :reactivate
    else      
      activation_code = params[:activation_code] 
      client = Client.find(:first, :conditions => {:id => params[:client_id]})
      if client && client.active && activation_code == client.activation_code
        # Activate the client
        client.activate
        flash[:message] = "Congratulations! Your account is now active. Please login."
        redirect_to :action => :login
      else 
        flash[:warning]  = "Invalid activation code. Maybe you've already activated. Try signing in."
        redirect_to :action => :login
      end
    end
  end
  
  def reactivate
    if request.post?
      c = Client.find(:first, :conditions => {:username => params[:username], :email => params[:email]})
      if c and c.send_activation
        flash[:message]  = "An activation code has been sent by email."
        redirect_to :action =>'login'
      else
        flash[:warning]  = "Could not find your account. Please enter a valid username and email."
      end
    end    
  end

end
