class ClientMailer < BaseMailer

  def activation(to, username, activation_code, sent_at = Time.now)
    @subject    = "Please activate your account"
    @username   = username
    @activation_code = activation_code
    @recipients = to
    @from       = 'admin@badg.net'
    @sent_on    = sent_at
    @headers    = {}
  end

  def forgot_password(to, username, password, sent_at = Time.now)
    @subject    = "Your password is ..."
    @username   = username
    @password   = password
    @recipients = to
    @from       = 'admin@badg.net'
    @sent_on    = sent_at
    @headers    = {}
  end
  
  def changed_email(to, username, old_email, new_email, sent_at = Time.now)
    @subject    = "You have changed your email"
    @username   = username
    @old_email  = old_email
    @new_email  = new_email 
    @recipients = to
    @from       = 'admin@badg.net'
    @sent_on    = sent_at
    @headers    = {}
  end

end
