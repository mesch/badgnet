require "digest"

class Client < ActiveRecord::Base
  validates_length_of :username, :within => 3..40
  validates_length_of :password, :within => 5..40
  validates_uniqueness_of :username, :email
  validates_presence_of :username, :email, :password, :password_confirmation, :salt
  validates_confirmation_of :password
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email."

  attr_protected :id, :salt
  attr_accessor :password, :password_confirmation

  has_many :badges
  has_many :badge_images
  has_many :actions

  # for reporting
  has_many :user_badges
  has_many :user_actions

  def self.authenticate(username, password)
    c=find(:first, :conditions=>["username = ?", username])
    return nil if c.nil?
    return c if Client.encrypt(password, c.salt)==c.hashed_password
    nil
  end  

  def password=(pass)
    @password=pass
    self.salt = Client.random_string(10) if !self.salt?
    self.hashed_password = Client.encrypt(@password, self.salt)
  end

=begin
  def send_new_password
    new_pass = Client.random_string(5)
    self.password = self.password_confirmation = new_pass
    self.save
    ActiveSupport::Notifications.deliver_forgot_password(self.email, self.username, new_pass)
  end
=end
   
  protected
   
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest(password+salt)
  end

  def self.random_string(len)
    #generate a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end

end
