class ClientMailer < BaseMailer

  def send_activation(to, username, client_id, activation_code)
    subject    = "Please activate your account"
    @username   = username
    @activation_code = activation_code
    @client_id = client_id
    mail(:to => to, :subject => subject)
  end

  def send_forgot_password(to, username, password)
    subject    = "Your password is ..."
    @username   = username
    @password   = password
    mail(:to => to, :subject => subject)
  end
  
  def send_changed_email(to, username, old_email, new_email)
    subject    = "You have changed your email"
    @username   = username
    @old_email  = old_email
    @new_email  = new_email 
    mail(:to => to, :subject => subject)
  end

end
