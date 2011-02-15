class ClientMailer < BaseMailer

  def self.activation(to, username, activation_code)
    subject    = "Please activate your account"
    @username   = username
    @activation_code = activation_code
    mail(:to => to, :subject => subject)
  end

  def self.forgot_password(to, username, password)
    subject    = "Your password is ..."
    @username   = username
    @password   = password
    mail(:to => to, :subject => subject)
  end
  
  def self.changed_email(to, username, old_email, new_email)
    subject    = "You have changed your email"
    @username   = username
    @old_email  = old_email
    @new_email  = new_email 
    mail(:to => to, :subject => subject)
  end

end
