require 'test_helper'

class ClientTest < ActiveSupport::TestCase
  self.use_instantiated_fixtures  = true
  fixtures :clients

  def equal? (c1, c2, columns=[])
    for column in columns
      if c1[column] != c2[column]
        return false
      end
    end
    return true
  end

  def test_auth 
    #check that we can login with a valid client
    assert_equal  @bob, Client.authenticate("bob", "test")    
    #wrong username
    assert_nil    Client.authenticate("nonbob", "test")
    #wrong password
    assert_nil    Client.authenticate("bob", "wrongpass")
    #wrong username and pass
    assert_nil    Client.authenticate("nonbob", "wrongpass")
  end

  def test_passwordchange
    # check success
    assert_equal @longbob, Client.authenticate("longbob", "longtest")
    #change password
    @longbob.password = @longbob.password_confirmation = "nonbobpasswd"
    assert @longbob.save
    #new password works
    assert_equal @longbob, Client.authenticate("longbob", "nonbobpasswd")
    #old pasword doesn't work anymore
    assert_nil   Client.authenticate("longbob", "longtest")
    #change back again
    @longbob.password = @longbob.password_confirmation = "longtest"
    assert @longbob.save
    assert_equal @longbob, Client.authenticate("longbob", "longtest")
    assert_nil   Client.authenticate("longbob", "nonbobpasswd")
  end

  def test_disallowed_passwords
    #check thaat we can't create a client with any of the disallowed paswords
    c = Client.new(:name => "test", :username => "nonexistingbob", :email => "test@abc.com", :salt => "1000", :activation_code => "1234")
    #too short
    c.password = c.password_confirmation = "wee" 
    assert !c.save     
    assert c.errors['password'].any?
    #too long
    c.password = c.password_confirmation = "hugehugehugehugehugehugehugehugehugehugehugehugehugehugehuge"
    assert !c.save     
    assert c.errors['password'].any?
    #empty
    c.password = c.password_confirmation = ""
    assert !c.save    
    assert c.errors['password'].any?
    #ok
    c.password = c.password_confirmation = "bobs_secure_password"
    assert c.save
    assert c.errors.empty? 
  end

  def test_bad_usernames
    #check we cant create a client with an invalid username
    c = Client.new(:name => "test", :username => "nonexistingbob", :email => "test@abc.com", :salt => "1000", :activation_code => "1234")
    c.password = c.password_confirmation = "bobs_secure_password"
    #too short
    c.username = "x"
    assert !c.save     
    assert c.errors['username'].any?
    #too long
    c.username = "hugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebob"
    assert !c.save     
    assert c.errors['username'].any?
    #empty
    c.username = ""
    assert !c.save
    assert c.errors['username'].any?
    #ok
    c.username = "okbob"
    assert c.save
    assert c.errors.empty?
    #no email
    c.email=nil   
    assert !c.save     
    assert c.errors['email'].any?
    #invalid email
    c.email='notavalidemail'   
    assert !c.save     
    assert c.errors['email'].any?
    #ok
    c.email="validtest@abc.com"
    assert c.save  
    assert c.errors.empty?
  end


  def test_collision
    #check can't create new user with existing username
    c = Client.new
    c.username = "existingbob"
    c.password = c.password_confirmation = "bobs_secure_password"
    assert !c.save
  end


  def test_create
    #check create works and we can authenticate after creation
    c = Client.new(:name => "test", :username => "nonexistingbob", :email => "test@abc.com", :salt => "1000", :activation_code => "1234")
    c.password = c.password_confirmation = "bobs_secure_password"
    assert_not_nil c.salt
    assert c.active
    assert c.save
    assert_equal 10, c.salt.length
    assert_equal c, Client.authenticate(c.username, c.password)

    c = Client.new(:name => "test", :username => "newbob", :email => "testtest@abc.com", :activation_code => "1234",
      :password => "newpassword", :password_confirmation => "newpassword")
    assert_not_nil c.salt
    assert_not_nil c.password
    assert_not_nil c.hashed_password
    assert c.save
    assert_equal c, Client.authenticate(c.username, c.password)
  end


  def test_send_new_password
    #check user authenticates
    assert_equal  @bob, Client.authenticate("bob", "test")    
    #send new password
    sent = @bob.send_new_password
    assert_not_nil sent
    #old password no longer workd
    assert_nil Client.authenticate("bob", "test")
### TODO - test this using delayed job?
=begin
    #email sent...
    assert_equal "Your password is ...", sent.subject
    #... to bob
    assert_equal @bob.email, sent.to[0]
    assert_match Regexp.new("Your username is bob."), sent.body.raw_source
    #can authenticate with the new password
    new_pass = $1 if Regexp.new("Your new password is (\\w+).") =~ sent.body.raw_source
    assert_not_nil new_pass
    assert_equal  @bob, Client.authenticate("bob", new_pass)
=end
  end


  def test_rand_str
    new_pass = Client.random_string(10)
    assert_not_nil new_pass
    assert_equal 10, new_pass.length
  end

  def test_sha1
    c = Client.new
    c.name = "test"
    c.username = "nonexistingbob"
    c.email = "test@abc.com"
    c.activation_code = "1234"
    c.salt = "1000"
    c.password = c.password_confirmation = "bobs_secure_password"
    assert c.save
    assert_equal 'b1d27036d59f9499d403f90e0bcf43281adaa844', c.hashed_password
    assert_equal 'b1d27036d59f9499d403f90e0bcf43281adaa844', Client.encrypt("bobs_secure_password", "1000")
  end

  def test_protected_attributes
    #check attributes are protected
    c = Client.new(:id=>999999, :name => "test", :salt=>"I-want-to-set-my-salt", :username => "badbob", :email => "test@abc.com", 
      :activation_code => "1234", :password => "newpassword", :password_confirmation => "newpassword")
    assert c.save
    assert_not_equal 999999, c.id
    assert_not_equal "I-want-to-set-my-salt", c.salt

    c.update_attributes(:id=>999999, :salt=>"I-want-to-set-my-salt", :username => "verybadbob")
    assert c.save
    assert_not_equal 999999, c.id
    assert_not_equal "I-want-to-set-my-salt", c.salt
    assert_equal "verybadbob", c.username
  end
  
  def test_activate
    assert !@inactivated.activated
    c = Client.find(@inactivated.id)
    assert c.activate
    assert c.activated
    assert equal?(c, @inactivated, [:name, :username, :hashed_password, :email, :salt, :activation_code, :active])
  end
  
  def test_inactivate
    assert @bob.activated
    c = Client.find(@bob)
    assert c.inactivate
    assert !c.activated
    assert equal?(c, @bob, [:name, :username, :hashed_password, :salt, :email, :activation_code, :active])
  end
  
  def test_update_email
    c = Client.find(@bob)
    # bad format
    assert !c.update_email("bad_format")
    c = Client.find(@bob) # save failed but c will have new password
    assert c.activated
    assert equal?(c, @bob, [:name, :username, :email, :hashed_password, :salt, :activation_code, :activate])
    # success
    assert c.update_email("test@abc.com")
    assert_equal c.email, "test@abc.com"
    assert !c.activated
    assert equal?(c, @bob, [:name, :username, :hashed_password, :salt, :activate])
  end
  
end
